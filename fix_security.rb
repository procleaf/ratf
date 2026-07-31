src = File.read("app/services/test_case_runner.rb")
src.sub!(/def self.run_command\(command_str\).*?end\n/m) do
<<~FIX
  SAFE_COMMANDS = %w[echo sleep hostname whoami ls pwd date df free uname id uptime env cat head tail wc sort uniq grep find stat du which].freeze
  BLOCKED = [/rm\\s+-rf/i, /curl\\b/i, /wget\\b/i, /sudo\\b/i, /chmod\\b/i, />\\s*\\/dev\\//i, /\\/etc\\/passwd/i, /kexec\\b/i, /systemctl\\b/i, /kill\\b/i, /pkill\\b/i].freeze

  def self.sanitize(cmd)
    cmd = cmd.to_s.strip
    base = cmd.split(/\\s+/).first.to_s
    return { safe: false, reason: "Not allowed", command: cmd } unless SAFE_COMMANDS.include?(base) || base.start_with?("echo")
    BLOCKED.each { |rx| return { safe: false, reason: "Blocked", command: cmd } if cmd.match?(rx) }
    { safe: true, reason: nil, command: cmd }
  end

  def self.run_command(command_str)
    r = sanitize(command_str)
    return Result.new(step: command_str, command: command_str, stdout: "", stderr: "BLOCKED", exit_code: -1, duration_ms: 0) unless r[:safe]
    require "open3"
    start = Process.clock_gettime(Process::CLOCK_MONOTONIC)
    stdout = ""; stderr = ""; exit_code = -1
    begin
      Timeout.timeout(60) { stdout, stderr_str, status = Open3.capture3("/bin/sh", "-c", r[:command], unsetenv_others: false); stderr = stderr_str; exit_code = status.exitstatus }
    rescue Timeout::Error; stderr = "Timeout"
    rescue => e; stderr = e.message
    end
    duration_ms = ((Process.clock_gettime(Process::CLOCK_MONOTONIC) - start) * 1000).round
    Result.new(step: command_str, command: command_str, stdout: stdout.to_s.strip, stderr: stderr.to_s.strip, exit_code: exit_code, duration_ms: duration_ms)
  end
FIX
end
File.write("app/services/test_case_runner.rb", src)
puts "Done: #{File.read("app/services/test_case_runner.rb").include?("sanitize")}"
