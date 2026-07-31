# frozen_string_literal: true
# RATF Seed Data — realistic automation test framework data
puts "Seeding RATF..."

# ── Users ──
admin = User.find_or_create_by!(email: "admin@ratf.local") do |u|
  u.username = "admin"
  u.password = "password123"
  u.role = :admin
  u.last_active_at = Time.now
end

manager = User.find_or_create_by!(email: "manager@ratf.local") do |u|
  u.username = "manager"
  u.password = "password123"
  u.role = :manager
  u.last_active_at = 5.minutes.ago
end

tester1 = User.find_or_create_by!(email: "alice@ratf.local") do |u|
  u.username = "alice"
  u.password = "password123"
  u.role = :user
  u.last_active_at = 1.hour.ago
end

tester2 = User.find_or_create_by!(email: "bob@ratf.local") do |u|
  u.username = "bob"
  u.password = "password123"
  u.role = :user
  u.last_active_at = 2.days.ago
end

viewer = User.find_or_create_by!(email: "eve@ratf.local") do |u|
  u.username = "eve"
  u.password = "password123"
  u.role = :user
end

puts "  #{User.count} users"

# ── Projects ──
core = Project.find_or_create_by!(name: "RATF Core") do |p|
  p.description = "Core test framework components — runner, scheduler, resource manager"
end

web = Project.find_or_create_by!(name: "RATF Web") do |p|
  p.description = "Web UI and API for test management dashboard"
end

integrations = Project.find_or_create_by!(name: "Integrations") do |p|
  p.description = "Third-party integrations: Slack, Jira, GitHub, PagerDuty"
end

puts "  #{Project.count} projects"

# ── Workers ──
5.times do |i|
  w = Worker.find_or_create_by!(name: host) do |wk|
    wk.host = host
    wk.parallel_jobs = [2, 4, 1, 8, 2][i]
    wk.capabilities = [%w[ruby python], %w[ruby nodejs python], %w[ruby], %w[ruby python go java], %w[ruby python]][i]
    wk.status = [:idle, :busy, :offline, :idle, :maintenance][i]
    wk.last_heartbeat_at = [Time.now, 2.minutes.ago, 15.minutes.ago, 1.minute.ago, nil][i]
  end
end

# ── Tags ──
tags = {}
%w[smoke regression performance security critical flaky].each do |name|
  tags[name] = Tag.find_or_create_by!(name: name)
end
puts "  #{Tag.count} tags"

# ── Test Suites & Cases ──
suite_data = [
  { name: "Smoke Tests", version: "1.0.0", project: core, status: :active,
    cases: [
      { name: "App boots without errors", type: :functional, priority: :critical, steps: ["Start Rails server", "Hit /up endpoint", "Verify 200 OK"] },
      { name: "Database connection", type: :functional, priority: :critical, steps: ["Check ActiveRecord connection", "Run a simple query", "Verify no errors"] },
      { name: "Login page renders", type: :acceptance, priority: :high, steps: ["Visit /login", "Check form fields", "Verify CSRF token present"] },
      { name: "Static assets served", type: :functional, priority: :medium, steps: ["Request /icon.png", "Check Content-Type", "Verify 200 OK"] },
    ]
  },
  { name: "Regression Suite", version: "2.1.0", project: core, status: :active,
    cases: [
      { name: "User CRUD operations", type: :functional, priority: :high, steps: ["Create user via API", "Read user", "Update user email", "Delete user"] },
      { name: "Job lifecycle", type: :integration, priority: :high, steps: ["Create job", "Queue job", "Run job", "Check completion status"] },
      { name: "Test result aggregation", type: :functional, priority: :medium, steps: ["Run 5 test cases", "Collect results", "Verify pass/fail counts", "Check suite stats"] },
    ]
  },
  { name: "Security Tests", version: "1.5.0", project: core, status: :active,
    cases: [
      { name: "SQL injection prevention", type: :security, priority: :critical, steps: ["Craft SQL injection payload", "Submit via search form", "Verify no data leak"] },
      { name: "XSS prevention", type: :security, priority: :critical, steps: ["Craft XSS payload", "Submit via comment form", "Verify script not executed"] },
      { name: "CSRF token validation", type: :security, priority: :high, steps: ["Submit form without CSRF token", "Verify 422 response", "Submit with valid token", "Verify 200"] },
    ]
  },
  { name: "API Tests", version: "3.0.0", project: web, status: :active,
    cases: [
      { name: "GET /api/v1/jobs", type: :functional, priority: :high, steps: ["Send GET /api/v1/jobs", "Verify JSON response", "Check pagination headers"] },
      { name: "POST /api/v1/jobs", type: :functional, priority: :high, steps: ["Send POST with valid body", "Verify 201 Created", "Check Location header"] },
      { name: "API rate limiting", type: :performance, priority: :medium, steps: ["Send 100 requests in 1s", "Verify 429 responses", "Wait for reset window", "Verify normal response"] },
      { name: "API authentication", type: :security, priority: :critical, steps: ["Send request without token", "Verify 401", "Send with invalid token", "Verify 401", "Send with valid token", "Verify 200"] },
    ]
  },
  { name: "UI Component Tests", version: "1.0.0", project: web, status: :active,
    cases: [
      { name: "Dashboard loads", type: :acceptance, priority: :high, steps: ["Visit /", "Check stat cards", "Verify navigation links"] },
      { name: "Job form validation", type: :acceptance, priority: :medium, steps: ["Visit /jobs/new", "Submit empty form", "Verify error messages", "Fill valid data", "Verify redirect"] },
      { name: "Responsive layout", type: :acceptance, priority: :low, steps: ["Resize to 375px", "Check nav collapse", "Resize to 1920px", "Check full layout"] },
    ]
  },
  { name: "Slack Integration", version: "0.9.0", project: integrations, status: :maintenance,
    cases: [
      { name: "Job failure notification", type: :integration, priority: :high, steps: ["Trigger job failure", "Verify Slack message sent", "Check message format"] },
      { name: "Daily summary", type: :integration, priority: :low, steps: ["Wait for scheduled time", "Verify summary posted", "Check stats accuracy"] },
    ]
  },
  { name: "Legacy Suite", version: "0.5.2", project: integrations, status: :deprecated,
    cases: [
      { name: "Old API v1", type: :functional, priority: :low, steps: ["Call deprecated endpoint", "Verify deprecation warning"] },
    ]
  },
]

suite_data.each do |sd|
  suite = TestSuite.find_or_create_by!(name: sd[:name], version: sd[:version]) do |ts|
    ts.project = sd[:project]
    ts.status = sd[:status]
    ts.metadata = { description: "#{sd[:name]} — #{sd[:cases].size} test cases", author: admin.username, tags: [sd[:name].downcase.split.first], dependencies: [] }
  end

  sd[:cases].each do |cd|
    tc = TestCase.find_or_create_by!(name: cd[:name], test_suite: suite) do |t|
      t.created_by = [admin, manager, tester1, tester2].sample
      t.status = [:active, :active, :active, :draft].sample
      t.priority = cd[:priority]
      t.test_type = cd[:type]
      t.definition = { steps: cd[:steps], preconditions: ["Environment ready"], expected_results: ["Test passes"], data: {} }
    end

    # Assign 1-2 random tags
    tags.values.sample(rand(1..2)).each do |tag|
      TestCaseTag.find_or_create_by!(test_case: tc, tag: tag)
    end
  end
end
puts "  #{TestSuite.count} test suites, #{TestCase.count} test cases, #{TestCaseTag.count} tag assignments"

# ── Jobs ──
job_defs = [
  { name: "Nightly Smoke Test", status: :completed, priority: :high, definition: { steps: %w[setup smoke-teardown], resources: { cpu: 2 }, environment: "staging" }, created_by: admin, started_at: 12.hours.ago, completed_at: 11.hours.ago },
  { name: "PR #342 Regression", status: :completed, priority: :high, definition: { steps: %w[checkout run compare], resources: { cpu: 4 }, environment: "ci" }, created_by: tester1, started_at: 3.hours.ago, completed_at: 2.5.hours.ago },
  { name: "Security Scan", status: :failed, priority: :critical, definition: { steps: %w[scan report], resources: { cpu: 8 }, environment: "production" }, created_by: manager, started_at: 1.hour.ago, completed_at: 45.minutes.ago },
  { name: "Release v2.1 Validation", status: :running, priority: :critical, definition: { steps: %w[deploy smoke performance security], resources: { cpu: 8 }, environment: "staging" }, created_by: admin, started_at: 10.minutes.ago },
  { name: "Weekly Performance Bench", status: :queued, priority: :normal, definition: { steps: %w[warmup bench analyze], resources: { cpu: 4 }, environment: "bench" }, created_by: tester2 },
  { name: "Flaky Test Investigation", status: :pending, priority: :low, definition: { steps: %w[rerun-flaky log-results], resources: { cpu: 1 }, environment: "staging" }, created_by: tester1 },
  { name: "Hotfix Smoke Test", status: :completed, priority: :critical, definition: { steps: %w[deploy smoke verify], resources: { cpu: 2 }, environment: "production" }, created_by: admin, started_at: 6.hours.ago, completed_at: 5.9.hours.ago },
  { name: "API Contract Tests", status: :failed, priority: :high, definition: { steps: %w[validate-contracts report], resources: { cpu: 2 }, environment: "ci" }, created_by: manager, started_at: 2.hours.ago, completed_at: 1.5.hours.ago },
]

jobs = job_defs.map do |jd|
  j = Job.find_or_create_by!(name: jd[:name]) do |job|
    job.description = "#{jd[:name]} — #{jd[:environment]} environment"
    job.status = jd[:status]
    job.priority = jd[:priority]
    job.definition = jd[:definition]
    job.created_by = jd[:created_by]
    job.started_at = jd[:started_at]
    job.completed_at = jd[:completed_at]
  end
end

# ── Job Runs ──
jobs.each do |job|
  next if job.pending? || job.queued?

  1.upto(rand(1..3)) do |run_num|
    status = job.completed? ? (run_num == 1 && rand < 0.3 ? :failed : :completed) : [:running, :completed, :failed].sample
    started = (job.started_at || 1.hour.ago) + (run_num - 1) * 2.minutes
    completed = status == :running ? nil : started + rand(30..600).seconds

      jr.status = job.running? ? :running : status
      jr.completed_at = completed
    end
  end

  # For completed jobs, also create a running run without finished_at for display
  if job.running?
    JobRun.find_or_create_by!(job: job, started_at: job.started_at) do |jr|
      jr.status = :running
    end
  end
end
puts "  #{Job.count} jobs, #{JobRun.count} job runs"

# ── Test Results ──
test_cases = TestCase.all.to_a
test_suites = TestSuite.all.to_a
job_runs = JobRun.all.to_a

test_cases.each do |tc|
  suite = tc.test_suite
  # Only create results for active test cases
  next unless tc.active?

  # Create 1-3 test results across different job runs
  rand(1..3).times do
    jr = job_runs.sample
    status = [:passed, :passed, :passed, :failed, :error, :skipped].sample
    exec_time = status == :skipped ? nil : rand(0.01..15.0).round(3)
    started = jr.started_at || 1.hour.ago
    ended = exec_time ? started + exec_time.seconds : nil

    TestResult.create!(
      job_run: jr,
      test_case: tc,
      test_suite: suite,
      name: "#{tc.name} — Run ##{rand(1..99)}",
      status: status,
      execution_time: exec_time,
      message: status == :passed ? "All assertions passed" : status == :failed ? "Expected 200 but got 500" : status == :error ? "Connection timeout" : nil,
      metadata: { browser: %w[chrome firefox safari].sample, environment: %w[staging production ci].sample, os: %w[linux macos windows].sample },
      started_at: started,
      ended_at: ended
    )
  end
end
puts "  #{TestResult.count} test results"

# ── Test Suite Runs ──
test_suites.each do |suite|
  job_runs.sample(rand(1..3)).each do |jr|
    results = TestResult.where(test_suite: suite, job_run: jr)
    next if results.empty?

    TestSuiteRun.find_or_create_by!(test_suite: suite, job_run: jr) do |tsr|
      tsr.status = [:completed, :completed, :failed].sample
      tsr.total_tests = results.count
      tsr.passed_tests = results.where(status: :passed).count
      tsr.failed_tests = results.where(status: :failed).count
      tsr.skipped_tests = results.where(status: :skipped).count
      tsr.errored_tests = results.where(status: :error).count
      tsr.total_duration = results.sum(:execution_time)
      tsr.started_at = jr.started_at
      tsr.ended_at = jr.completed_at
    end
  end
end
puts "  #{TestSuiteRun.count} test suite runs"

# ── Issues ──
failed_results = TestResult.where(status: [:failed, :error]).limit(5)
issue_data = [
  { title: "Dashboard widget rendering fails on Firefox", severity: :major, urgency: :high, issue_type: :bug },
  { title: "API timeout under concurrent load", severity: :critical, urgency: :critical, issue_type: :bug },
  { title: "Login button misaligned on mobile", severity: :minor, urgency: :low, issue_type: :bug },
  { title: "Add support for WebSocket log streaming", severity: :trivial, urgency: :medium, issue_type: :feature_request },
  { title: "Refactor resource manager to use connection pool", severity: :major, urgency: :medium, issue_type: :technical_debt },
]

issue_data.each_with_index do |id, i|
  Issue.find_or_create_by!(title: id[:title]) do |issue|
    issue.description = "#{id[:title]} — reported from automated test run."
    issue.status = [:open, :in_progress, :resolved, :open, :in_progress][i]
    issue.severity = id[:severity]
    issue.urgency = id[:urgency]
    issue.issue_type = id[:issue_type]
    issue.reported_by = [admin, manager, tester1, tester2].sample
    issue.assigned_to = [admin, manager, tester1, nil].sample
    issue.closed_at = issue.resolved? ? rand(1..5).days.ago : nil
    if (tr = failed_results[i])
      issue.test_case = tr.test_case
      issue.test_result = tr
    end
  end
end
puts "  #{Issue.count} issues"

# ── Issue Comments ──
Issue.all.each do |issue|
  rand(1..3).times do
    IssueComment.create!(
      issue: issue,
      user: [admin, manager, tester1, tester2].sample,
      content: ["Investigating this now.", "Found the root cause — null check missing.", "Fix deployed to staging.", "Verified the fix works.", "Can we add a regression test for this?"].sample
    )
  end
end
puts "  #{IssueComment.count} issue comments"

# ── Posts ──
[
  { title: "Release Notes v2.1", content: "We are pleased to announce RATF v2.1 with improved parallel execution, WebSocket log streaming, and a redesigned dashboard.", user: admin },
  { title: "Testing Best Practices", content: "Here are 5 best practices for writing reliable test suites: 1) Keep tests independent, 2) Use descriptive names, 3) One assertion per test, 4) Clean up resources, 5) Run flaky test detection weekly.", user: manager },
  { title: "Upcoming Maintenance", content: "The CI pipeline will be down for maintenance on Saturday 2-4 AM UTC. No tests will run during this window.", user: admin },
].each do |pd|
  Post.find_or_create_by!(title: pd[:title]) do |post|
    post.content = pd[:content]
    post.user = pd[:user]
  end
end
puts "  #{Post.count} posts"

# ── Logs & Log Entries ──
job_runs.sample(5).each do |jr|
  log = Log.create!(job_run: jr, content: [
    "[#{jr.started_at&.iso8601}] [INFO] Test suite execution started",
    "[#{(jr.started_at || Time.now) + 5.seconds}] [INFO] Running #{jr.job.name}",
    "[#{(jr.started_at || Time.now) + 30.seconds}] [WARN] Slow test detected: API Contract Tests",
    "[#{(jr.started_at || Time.now) + 60.seconds}] [INFO] #{jr.status == :completed ? 'All tests passed' : 'Test suite completed with failures'}",
  ].join("\n"))

  3.times do |i|
    LogEntry.create!(
      job_run: jr,
      log_level: [:debug, :info, :warn, :error].sample,
      message: ["Test execution started", "Step #{i + 1} completed", "Assertion passed", "Resource cleaned up"].sample,
      source: "ratf-runner",
      timestamp: (jr.started_at || Time.now) + i * 10.seconds
    )
  end
end
puts "  #{Log.count} logs, #{LogEntry.count} log entries"

# ── Notifications ──
[
  { user: admin, type: :job_completed, message: "Job 'Nightly Smoke Test' completed successfully — 45/45 passed" },
  { user: manager, type: :job_failed, message: "Job 'Security Scan' failed — 2 vulnerabilities found" },
  { user: tester1, type: :issue_assignment, message: "Issue #1 assigned to you: Dashboard widget rendering fails on Firefox" },
  { user: tester2, type: :issue_comment, message: "New comment on issue #2: 'Found the root cause'" },
  { user: admin, type: :test_failure, message: "Test 'API rate limiting' failed in Regression Suite" },
  { user: manager, type: :system, message: "System maintenance scheduled for Saturday 2 AM UTC" },
  { user: tester1, type: :job_completed, message: "Job 'PR #342 Regression' completed — 23/25 passed" },
].each do |nd|
  Notification.create!(
    user: nd[:user],
    notification_type: nd[:type],
    message: nd[:message],
    read_at: rand < 0.5 ? nil : rand(1..24).hours.ago
  )
end
puts "  #{Notification.count} notifications"

# ── Demo: System Smoke Test (runnable!) ──
puts "  Creating demo test case..."
demo_suite = TestSuite.find_or_create_by!(name: "Smoke Tests", version: "1.0.0") do |ts|
  ts.project = core
  ts.status = :active
  ts.metadata = { description: "Quick system sanity checks", author: "admin", tags: ["smoke", "demo"], dependencies: [] }
end

demo_tc = TestCase.find_or_create_by!(name: "System Smoke Test", test_suite: demo_suite) do |tc|
  tc.created_by = admin
  tc.status = :active
  tc.priority = :high
  tc.test_type = :functional
  tc.description = "Runs basic system commands to verify the test runner works. Each step is a real Linux command."
  tc.definition = {
    steps: [
      "echo 'RATF system check starting...'",
      "sleep 1",
      "hostname",
      "whoami",
      "ls /tmp | head -5",
      "echo 'All checks passed' && exit 0"
    ],
    preconditions: ["Linux system with standard utilities"],
    expected_results: ["All commands complete successfully with exit code 0"],
    data: {}
  }
end
puts "     Demo test case: #{demo_tc.name} (##{demo_tc.id})"

# ── Selenium Demo: Browser Smoke Test ──
puts "  Creating Selenium demo..."
selenium_tc = TestCase.find_or_create_by!(name: "Browser Smoke Test (Selenium)", test_suite: demo_suite) do |tc|
  tc.created_by = admin
  tc.status = :active
  tc.priority = :high
  tc.test_type = :browser
  tc.description = "Opens google.com, searches, and checks the title. Uses headless Chrome."
  tc.definition = {
    steps: [
      'driver.navigate.to "https://www.google.com"',
      'sleep 1',
      'raise "Title mismatch" unless driver.title.downcase.include?("google")',
      'driver.find_element(name: "q").send_keys "RATF test framework"',
      'driver.find_element(name: "q").submit',
      'sleep 1',
      'raise "No results" unless driver.find_elements(css: "h3").any?'
    ],
    preconditions: ["Chrome browser installed", "Internet access"],
    expected_results: ["Google loads", "Search returns results"],
    capabilities: { browser: "chrome", headless: true }
  }
end
puts "     Selenium demo: #{selenium_tc.name} (##{selenium_tc.id})"

# ── Appium Demo: Mobile App Smoke Test ──
puts "  Creating Appium demo..."
appium_tc = TestCase.find_or_create_by!(name: "Mobile App Smoke Test (Appium)", test_suite: demo_suite) do |tc|
  tc.created_by = admin
  tc.status = :active
  tc.priority = :high
  tc.test_type = :mobile
  tc.description = "Launches the app, checks the login screen, verifies elements. Requires Appium server running on localhost:4723."
  tc.definition = {
    steps: [
      'sleep 2',
      'raise "App did not launch" if driver.page_source.empty?',
      'login_btn = driver.find_element(accessibility_id: "loginButton") rescue nil',
      'raise "Login button not found" unless login_btn',
      'raise "Login button not enabled" unless login_btn.enabled?'
    ],
    preconditions: ["Appium server running on localhost:4723", "Android emulator connected", "App installed"],
    expected_results: ["App launches", "Login screen visible", "Login button present and enabled"],
    capabilities: { platform: "android", device: "emulator", app_path: "/path/to/app.apk", server_url: "http://localhost:4723" }
  }
end
puts "     Appium demo: #{appium_tc.name} (##{appium_tc.id})"

# ── NL Demo: Natural Language Smoke Test ──
puts "  Creating NL demo..."
nl_tc = TestCase.find_or_create_by!(name: "Natural Language Smoke Test", test_suite: demo_suite) do |tc|
  tc.created_by = admin
  tc.status = :active
  tc.priority = :high
  tc.test_type = :natural_language
  tc.description = "Uses natural language steps that are auto-translated to Selenium/shell commands."
  tc.definition = {
    steps: [
      "Open https://www.google.com",
      "Wait 2 seconds",
      "Check the page title contains \"Google\"",
      "Type \"RATF natural language test\" in the search box",
      "Click the search button",
      "Wait 2 seconds",
      "Run echo \"NL test finished successfully\""
    ],
    preconditions: ["Chrome browser installed"],
    expected_results: ["Google search page loads and search executes"],
    capabilities: { browser: "chrome", headless: true }
  }
end
puts "     NL demo: #{nl_tc.name} (##{nl_tc.id})"

puts ""
puts "✅ Seed complete! Summary:"
puts "   #{User.count} users | #{Project.count} projects | #{TestSuite.count} test suites"
puts "   #{TestCase.count} test cases | #{Tag.count} tags | #{TestCaseTag.count} tag assignments"
puts "   #{TestResult.count} test results | #{TestSuiteRun.count} suite runs"
puts "   #{Issue.count} issues | #{IssueComment.count} comments"
puts "   #{Post.count} posts | #{Log.count} logs | #{LogEntry.count} log entries"
puts "   #{Notification.count} notifications"
