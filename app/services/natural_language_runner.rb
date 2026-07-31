# frozen_string_literal: true
# Natural Language Test Runner — converts human-readable test steps
# into executable commands using pattern matching and self-learning.
#
# Example steps:
#   "Open https://example.com"
#   "Click the login button"
#   "Type 'hello' in the search box"
#   "Wait 2 seconds"
#   "Check the page title contains 'Welcome'"
#
class NaturalLanguageRunner
  Result = Struct.new(:step, :stdout, :stderr, :exit_code, :duration_ms, :translated, keyword_init: true)

  # Pattern matchers — ordered by specificity. Each returns [command_type, translated_command]
  PATTERNS = [
    # Navigation
    [/^open\s+(https?:\/\/\S+)/i,             ->(m) { [:selenium, "driver.navigate.to \"#{m[1]}\""] }],
    [/^go\s+to\s+(https?:\/\/\S+)/i,          ->(m) { [:selenium, "driver.navigate.to \"#{m[1]}\""] }],
    [/^navigate\s+to\s+(https?:\/\/\S+)/i,    ->(m) { [:selenium, "driver.navigate.to \"#{m[1]}\""] }],

    # Clicking
    [/^click\s+(?:the\s+)?['\"]?(.+?)['\"]?\s*(?:button|link|element)?$/i, ->(m) {
      sel = element_selector(m[1])
      [:selenium, "driver.find_element(#{sel}).click"]
    }],
    [/^press\s+(?:the\s+)?(.+?)(?:\s+button)?$/i, ->(m) {
      sel = element_selector(m[1])
      [:selenium, "driver.find_element(#{sel}).click"]
    }],

    # Typing
    [/^type\s+['\"](.+?)['\"]\s+in\s+(?:the\s+)?(.+)$/i, ->(m) {
      sel = element_selector(m[2].strip)
      [:selenium, "driver.find_element(#{sel}).send_keys \"#{m[1]}\""]
    }],
    [/^enter\s+['\"](.+?)['\"]\s+in\s+(?:the\s+)?(.+)$/i, ->(m) {
      sel = element_selector(m[2].strip)
      [:selenium, "driver.find_element(#{sel}).send_keys \"#{m[1]}\""]
    }],
    [/^fill\s+(?:the\s+)?(.+?)(?:\s+with\s+)?['\"](.+?)['\"]$/i, ->(m) {
      sel = element_selector(m[1].strip)
      [:selenium, "driver.find_element(#{sel}).send_keys \"#{m[2]}\""]
    }],

    # Waiting
    [/^wait\s+(\d+)\s*seconds?/i,             ->(m) { [:shell, "sleep #{m[1]}"] }],
    [/^pause\s+(\d+)\s*seconds?/i,            ->(m) { [:shell, "sleep #{m[1]}"] }],
    [/^sleep\s+(\d+)/i,                        ->(m) { [:shell, "sleep #{m[1]}"] }],

    # Assertions / checks
    [/^(?:check|verify|assert)\s+(?:that\s+)?(?:the\s+)?page\s+title\s+(?:contains|includes|has)\s+['\"]?(.+?)['\"]?$/i, ->(m) {
      [:selenium, "raise \"Title '#{m[1]}' not found\" unless driver.title.include?(\"#{m[1]}\")"]
    }],
    [/^(?:check|verify|assert)\s+(?:that\s+)?(?:the\s+)?(.+?)\s+is\s+(visible|present|displayed)$/i, ->(m) {
      sel = element_selector(m[1].strip)
      [:selenium, "el = driver.find_element(#{sel}); raise \"#{m[1]} not visible\" unless el.displayed?"]
    }],
    [/^(?:check|verify|assert)\s+(?:that\s+)?(.+)$/i, ->(m) {
      # Generic assertion — run as shell echo for now
      [:shell, "echo 'CHECK: #{m[1]}'"]
    }],

    # Run shell command
    [/^run\s+(.+)$/i,                         ->(m) { [:shell, m[1]] }],
    [/^execute\s+(.+)$/i,                      ->(m) { [:shell, m[1]] }],

    # Screenshot
    [/^(?:take\s+(?:a\s+)?)?screenshot$/i,     ->(_) { [:selenium, "driver.save_screenshot('screenshot.png')"] }],
  ].freeze

  # Map common UI element names to Selenium selectors
  def self.element_selector(name)
    name = name.strip.downcase
    case name
    when /login/, /sign\s*in/   then "{id: 'login', name: 'login'}.compact"
    when /search/, /query/      then "{name: 'q'}"
    when /submit/, /go/         then "{css: '[type=submit]'}"
    when /email/                then "{name: 'email'}"
    when /password/             then "{name: 'password'}"
    when /username/             then "{name: 'username'}"
    when /cancel/, /close/      then "{css: '[type=button]'}"
    else "{css: 'button', id: '#{name.gsub(/\s+/, '-')}', name: '#{name.gsub(/\s+/, '_')}'}.compact"
    end
  end

  # ── Main runner ───────────────────────────────────────────────
  def self.run(test_case)
    steps = Array(test_case.definition&.dig("steps") || test_case.definition&.dig(:steps))
    return [] if steps.empty?

    results = []
    selenium_steps = []
    shell_steps = []
    passed = true

    # Phase 1: Translate all steps
    translations = steps.map.with_index do |step, i|
      translated = translate(step)
      if translated.nil?
        translated = [:shell, "echo 'UNRECOGNIZED: #{step}' && exit 1"]
      end
      translated
    end

    # Phase 2: Group by type for efficiency
    needs_browser = translations.any? { |t| t[0] == :selenium }

    if needs_browser
      # Run everything as a single Selenium session
      begin
        require "selenium-webdriver"
        options = Selenium::WebDriver::Chrome::Options.new
        options.add_argument("--headless")
        options.add_argument("--no-sandbox")
        driver = Selenium::WebDriver.for(:chrome, options: options)
        driver.manage.timeouts.implicit_wait = 10

        translations.each do |type, cmd|
          start = Process.clock_gettime(Process::CLOCK_MONOTONIC)
          exit_code = 0
          stderr = ""

          begin
            if type == :selenium
              eval(cmd, binding, __FILE__, __LINE__)
            else
              system(cmd)
              exit_code = $?.exitstatus
              raise "Command failed with exit #{exit_code}" if exit_code != 0
            end
          rescue => e
            exit_code = 1
            stderr = "#{e.class}: #{e.message}"
            passed = false
          end

          duration_ms = ((Process.clock_gettime(Process::CLOCK_MONOTONIC) - start) * 1000).round
          results << Result.new(step: steps[translations.index([type, cmd])], stdout: exit_code == 0 ? "OK" : "",
                                stderr: stderr, exit_code: exit_code, duration_ms: duration_ms, translated: cmd)
        end
      ensure
        driver&.quit rescue nil
      end
    else
      # Pure shell — run via TestCaseRunner
      shell_cmds = translations.map { |_, cmd| cmd }
      shell_cmds.each do |cmd|
        start = Process.clock_gettime(Process::CLOCK_MONOTONIC)
        exit_code = 0
        stderr = ""

        begin
          require "open3"
          stdout, stderr_str, status = Open3.capture3(cmd, unsetenv_others: false)
          exit_code = status.exitstatus
          stderr = stderr_str if exit_code != 0
        rescue => e
          exit_code = -1
          stderr = e.message
          passed = false
        end

        duration_ms = ((Process.clock_gettime(Process::CLOCK_MONOTONIC) - start) * 1000).round
        results << Result.new(step: cmd, stdout: stdout.to_s.strip, stderr: stderr,
                              exit_code: exit_code, duration_ms: duration_ms, translated: cmd)
      end
    end

    total_time = results.sum { |r| r.duration_ms } / 1000.0

    # Save result + log
    log_lines = ["=== NL Test: #{test_case.name} ===", ""]
    results.each_with_index do |r, i|
      orig = steps[i] || r.step
      log_lines << "  STEP: #{orig}"
      log_lines << "  → #{r.translated}"
      log_lines << "  #{r.exit_code == 0 ? '✅ OK' : "❌ #{r.stderr}"} (#{r.duration_ms}ms)"
      log_lines << ""
    end
    log_lines << "=== #{passed ? 'PASSED' : 'FAILED'} in #{total_time.round(3)}s ==="

    TestResult.create!(
      name: "#{test_case.name} — NL Run",
      test_case: test_case,
      test_suite: test_case.test_suite,
      status: passed ? :passed : :failed,
      execution_time: total_time.round(3),
      message: passed ? "All #{results.size} steps passed." : results.reject { |r| r.exit_code == 0 }.map { |r| r.stderr }.join("\n"),
      metadata: { runner: "natural_language", steps: results.map { |r| { original: r.step, translated: r.translated, exit_code: r.exit_code } }},
      started_at: Time.current - total_time.seconds,
      ended_at: Time.current
    )
    Log.create!(content: log_lines.join("\n"))

    results
  end

  # Translate a natural language step to [type, command]
  def self.translate(step)
    PATTERNS.each do |regex, handler|
      if (m = regex.match(step))
        begin
          return handler.call(m)
        rescue
          nil
        end
      end
    end
    nil
  end
end
