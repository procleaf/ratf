# frozen_string_literal: true
# Executes mobile app test steps using Appium.
# Steps are Ruby code strings that use the `driver` object.
#
# Example test case steps:
#   driver.find_element(accessibility_id: "loginButton").click
#   driver.find_element(name: "username").send_keys "testuser"
class AppiumRunner
  Result = Struct.new(:step, :stdout, :stderr, :exit_code, :duration_ms, keyword_init: true)

  def self.run(test_case)
    require "appium_lib"
    steps = Array(test_case.definition&.dig("steps") || test_case.definition&.dig(:steps))
    return [] if steps.empty?

    caps = test_case.definition&.dig("capabilities") || {}
    platform = caps["platform"] || "android"
    device = caps["device"] || "emulator"

    opts = {
      caps: {
        platformName: platform.capitalize,
        "appium:automationName" => "UiAutomator2",
        "appium:deviceName" => device,
        "appium:app" => caps["app_path"]
      }.compact,
      appium_lib: { server_url: caps["server_url"] || "http://localhost:4723" }
    }

    driver = nil
    results = []
    passed = true

    begin
      driver = Appium::Driver.new(opts, true)
      driver.start_driver
    rescue => e
      msg = "Unable to connect to Appium at #{opts[:appium_lib][:server_url]}: #{e.message}"
      TestResult.create!(name: "#{test_case.name} — Mobile Run (failed)", test_case: test_case, test_suite: test_case.test_suite, status: :error, execution_time: 0, message: msg)
      Log.create!(content: msg)
      return [Result.new(step: "connect", stdout: "", stderr: msg, exit_code: -1, duration_ms: 0)]
    end

    begin
      steps.each do |step|
        start = Process.clock_gettime(Process::CLOCK_MONOTONIC)
        exit_code = 0
        stderr = ""

        begin
          Timeout.timeout(30) do
            eval(step, binding, __FILE__, __LINE__)
          end
        rescue => e
          exit_code = 1
          stderr = "#{e.class}: #{e.message}"
          passed = false
        end

        duration_ms = ((Process.clock_gettime(Process::CLOCK_MONOTONIC) - start) * 1000).round
        results << Result.new(step: step, stdout: exit_code == 0 ? "OK" : "", stderr: stderr, exit_code: exit_code, duration_ms: duration_ms)
      end
    ensure
      driver&.driver_quit rescue nil
    end

    total_time = results.sum { |r| r.duration_ms } / 1000.0
    log_lines = ["=== Mobile Test: #{test_case.name} ===", "Platform: #{platform}", "Device: #{device}", ""]
    results.each { |r| log_lines << "$ #{r.step}\n  #{r.exit_code == 0 ? 'OK' : "FAIL: #{r.stderr}"} (#{r.duration_ms}ms)" }
    log_lines << "=== #{passed ? 'PASSED' : 'FAILED'} in #{total_time.round(3)}s ==="

    TestResult.create!(
      name: "#{test_case.name} — Mobile Run",
      test_case: test_case,
      test_suite: test_case.test_suite,
      status: passed ? :passed : :failed,
      execution_time: total_time.round(3),
      message: passed ? "All mobile steps passed." : results.select { |r| r.exit_code != 0 }.map { |r| r.stderr }.join("\n"),
      metadata: { runner: "appium", platform: platform, device: device },
      started_at: Time.current - total_time.seconds,
      ended_at: Time.current
    )
    Log.create!(content: log_lines.join("\n"))

    results
  end
end
