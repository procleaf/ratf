# frozen_string_literal: true
# Executes browser-based test steps using Selenium WebDriver.
# Steps are Ruby code strings that use the `driver` object.
#
# Example test case steps:
#   driver.navigate.to "https://example.com"
#   driver.find_element(name: "q").send_keys "hello"
#   driver.find_element(name: "q").submit
class SeleniumRunner
  Result = Struct.new(:step, :stdout, :stderr, :exit_code, :duration_ms, keyword_init: true)

  def self.run(test_case)
    begin
      require "selenium-webdriver"
    rescue LoadError
      msg = "selenium-webdriver gem not installed. Run: bundle add selenium-webdriver"
      TestResult.create!(name: "#{test_case.name} — Browser Run (failed)", test_case: test_case, test_suite: test_case.test_suite, status: :error, execution_time: 0, message: msg)
      Log.create!(content: msg)
      return [Result.new(step: "setup", stdout: "", stderr: msg, exit_code: -1, duration_ms: 0)]
    end

    steps = Array(test_case.definition&.dig("steps") || test_case.definition&.dig(:steps))
    return [] if steps.empty?

    caps = test_case.definition&.dig("capabilities") || {}
    browser = caps["browser"] || "chrome"
    headless = caps["headless"] != false

    options = case browser
    when "firefox" then Selenium::WebDriver::Firefox::Options.new
    when "safari" then Selenium::WebDriver::Safari::Options.new
    else Selenium::WebDriver::Chrome::Options.new
    end
    options.add_argument("--headless") if headless && browser != "safari"
    options.add_argument("--no-sandbox")
    options.add_argument("--disable-dev-shm-usage")

    driver = Selenium::WebDriver.for(browser.to_sym, options: options)
    driver.manage.timeouts.implicit_wait = 10
    results = []
    passed = true

    begin
      steps.each do |step|
        start = Process.clock_gettime(Process::CLOCK_MONOTONIC)
        stdout = ""
        exit_code = 0
        stderr = ""

        begin
          Timeout.timeout(30) do
            eval(step, binding, __FILE__, __LINE__)
          end
          stdout = "OK"
        rescue => e
          exit_code = 1
          stderr = "#{e.class}: #{e.message}"
          passed = false
        end

        duration_ms = ((Process.clock_gettime(Process::CLOCK_MONOTONIC) - start) * 1000).round
        results << Result.new(step: step, stdout: stdout, stderr: stderr, exit_code: exit_code, duration_ms: duration_ms)
      end
    ensure
      driver.quit rescue nil
    end

    total_time = results.sum { |r| r.duration_ms } / 1000.0
    log_lines = ["=== Browser Test: #{test_case.name} ===", "Browser: #{browser}", "Headless: #{headless}", ""]
    results.each { |r| log_lines << "$ #{r.step}\n  #{r.exit_code == 0 ? 'OK' : "FAIL: #{r.stderr}"} (#{r.duration_ms}ms)" }
    log_lines << "=== #{passed ? 'PASSED' : 'FAILED'} in #{total_time.round(3)}s ==="

    TestResult.create!(
      name: "#{test_case.name} — Browser Run",
      test_case: test_case,
      test_suite: test_case.test_suite,
      status: passed ? :passed : :failed,
      execution_time: total_time.round(3),
      message: passed ? "All browser steps passed." : results.select { |r| r.exit_code != 0 }.map { |r| r.stderr }.join("\n"),
      metadata: { runner: "selenium", browser: browser, headless: headless },
      started_at: Time.current - total_time.seconds,
      ended_at: Time.current
    )
    Log.create!(content: log_lines.join("\n"))

    results
  end
end
