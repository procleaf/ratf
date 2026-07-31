require "test_helper"

class TestSuiteRunTest < ActiveSupport::TestCase
  test "valid with required attributes" do
    run = test_suite_runs(:smoke_suite_run)
    assert run.valid?
  end

  test "enum status has correct values" do
    expected = { "pending" => 0, "running" => 1, "completed" => 2, "failed" => 3 }
    assert_equal expected, TestSuiteRun.statuses
  end

  test "belongs_to test_suite" do
    run = test_suite_runs(:smoke_suite_run)
    assert_respond_to run, :test_suite
    assert_equal test_suites(:smoke_suite), run.test_suite
  end

  test "belongs_to job_run" do
    run = test_suite_runs(:smoke_suite_run)
    assert_respond_to run, :job_run
    assert_equal job_runs(:completed_run), run.job_run
  end

  test "invalid with duplicate test_suite in same job_run" do
    existing = test_suite_runs(:smoke_suite_run)
    dup = TestSuiteRun.new(test_suite: existing.test_suite, job_run: existing.job_run)
    assert_not dup.valid?
    assert_includes dup.errors[:test_suite_id], "has already been taken"
  end

  test "duration returns nil without ended_at" do
    run = test_suite_runs(:regression_suite_run_pending)
    assert_nil run.duration
  end

  test "duration computes seconds between start and end" do
    run = test_suite_runs(:smoke_suite_run)
    duration = run.duration
    assert duration.is_a?(Float)
    assert duration > 0
  end

  test "success_rate computes correctly" do
    run = test_suite_runs(:smoke_suite_run)
    rate = run.success_rate
    assert_equal 50.0, rate
  end

  test "success_rate returns 0 when no tests" do
    run = test_suite_runs(:regression_suite_run_pending)
    assert_equal 0, run.success_rate
  end
end
