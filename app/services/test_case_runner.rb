# frozen_string_literal: true
# Executes test case steps as shell commands with safety sanitization.
class TestCaseRunner
  Result = Struct.new(:step, :command, :stdout, :stderr, :exit_code, :duration_ms, keyword_init: true)

  SAFE_COMMANDS = %w[echo sleep hostname whoami ls pwd date df free uname id uptime env cat head tail wc sort uniq grep find stat du which].freeze
  BLOCKED_PATTERNS = [/rm\s+-rf/i, /curl\b/i, /wget\b/i, /sudo\b/i, /chmod\b/i, />\s*\/dev\//i, /\/etc\/passwd/i, /kexec\b/i, /systemctl\b/i, /kill\b/i, /pkill\b/i].freeze

  def self.sanitize(cmd)
    c = cmd.to_s.strip
    base = c.split(/\s+/).first.to_s
    return { safe: false, reason: "Not allowed: #{base}", command: c } unless SAFE_COMMANDS.include?(base) || base.start_with?("echo")
    BLOCKED_PATTERNS.each { |rx| return { safe: false, reason: "Blocked pattern", command: c } if c.match?(rx) }
    { safe: true, reason: nil, command: c }
  end

  def self.run(test_case)
    case test_case.test_type
    when "browser" then return SeleniumRunner.run(test_case)
    when "mobile" then return AppiumRunner.run(test_case)
    when "natural_language" then return NaturalLanguageRunner.run(test_case)
    end
    steps = Array(test_case.definition&.dig("steps") || test_case.definition&.dig(:steps))
    return [] if steps.empty?
    results = steps.map { |s| run_command(s) }
    passed = results.all? { |r| r.exit_code == 0 }
    total_time = results.sum { |r| r.duration_ms } / 1000.0
    TestResult.create!(
      name: "#{test_case.name} - Manual Run", test_case: test_case, test_suite: test_case.test_suite,
      status: passed ? :passed : :failed, execution_time: total_time.round(3),
      message: results.reject { |r| r.exit_code == 0 }.map { |r| "Step '#{r.step}' failed: #{r.stderr}" }.join("\n").presence || "All steps passed.",
      metadata: { runner: "manual", steps: results.map { |r| { step: r.step, command: r.command, exit_code: r.exit_code, duration_ms: r.duration_ms } } },
      started_at: Time.current - total_time.seconds, ended_at: Time.current)
    log_lines = ["=== Test Case: #{test_case.name} ===", "Started: #{Time.current}", ""]
    results.each { |r| log_lines << "$ #{r.step}"; log_lines << "  stdout: #{r.stdout}" if r.stdout.present?; log_lines << "  stderr: #{r.stderr}" if r.stderr.present?; log_lines << "  exit: #{r.exit_code} (#{r.duration_ms}ms)"; log_lines << "" }
    log_lines << "=== #{passed ? 'PASSED' : 'FAILED'} in #{total_time.round(3)}s ==="
    Log.create!(content: log_lines.join("\n"))
    results
  end

  def self.run_command(command_str)
    r = sanitize(command_str)
    return Result.new(step: command_str, command: command_str, stdout: "", stderr: "BLOCKED: #{r[:reason]}", exit_code: -1, duration_ms: 0) unless r[:safe]
    require "open3"
    start = Process.clock_gettime(Process::CLOCK_MONOTONIC)
    stdout = ""; stderr = ""; exit_code = -1
    begin
      Timeout.timeout(60) do
        stdout, stderr_str, status = Open3.capture3("/bin/sh", "-c", r[:command], unsetenv_others: false)
        stderr = stderr_str; exit_code = status.exitstatus
      end
    rescue Timeout::Error; stderr = "Timeout"
    rescue => e; stderr = e.message
    end
    duration_ms = ((Process.clock_gettime(Process::CLOCK_MONOTONIC) - start) * 1000).round
    Result.new(step: command_str, command: command_str, stdout: stdout.to_s.strip, stderr: stderr.to_s.strip, exit_code: exit_code, duration_ms: duration_ms)
  end
end
