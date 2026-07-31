require "test_helper"

class TestResultTest < ActiveSupport::TestCase
  test "valid with required attributes" do
    result = test_results(:login_passed)
    assert result.valid?
  end

  test "invalid without name" do
    result = test_results(:login_passed)
    result.name = nil
    assert_not result.valid?
    assert_includes result.errors[:name], "can't be blank"
  end

  test "passed result requires execution_time" do
    result = test_results(:login_passed)
    result.execution_time = nil
    assert_not result.valid?
    assert_includes result.errors[:execution_time], "can't be blank"
  end

  test "failed result requires execution_time" do
    result = test_results(:dashboard_failed)
    result.execution_time = nil
    assert_not result.valid?
    assert_includes result.errors[:execution_time], "can't be blank"
  end

  test "skipped result does not require execution_time" do
    result = test_results(:skipped_result)
    assert result.valid?
  end

  test "enum status has correct values" do
    expected = { "passed" => 0, "failed" => 1, "error" => 2, "skipped" => 3, "pending" => 4 }
    assert_equal expected, TestResult.statuses
  end

  test "belongs_to job_run optional" do
    result = test_results(:login_passed)
    assert_respond_to result, :job_run
    assert_equal job_runs(:completed_run), result.job_run
  end

  test "belongs_to test_case optional" do
    result = test_results(:login_passed)
    assert_respond_to result, :test_case
    assert_equal test_cases(:login_test), result.test_case
  end

  test "belongs_to test_suite optional" do
    result = test_results(:login_passed)
    assert_respond_to result, :test_suite
    assert_equal test_suites(:smoke_suite), result.test_suite
  end

  test "success? returns true for passed" do
    assert test_results(:login_passed).success?
  end

  test "success? returns false for failed" do
    assert_not test_results(:dashboard_failed).success?
  end

  test "failure? returns true for failed" do
    assert test_results(:dashboard_failed).failure?
  end

  test "failure? returns true for error" do
    assert test_results(:api_error).failure?
  end

  test "failure? returns false for passed" do
    assert_not test_results(:login_passed).failure?
  end

  test "failure_message returns nil for success" do
    assert_nil test_results(:login_passed).failure_message
  end

  test "failure_message returns message for failure" do
    assert_equal "Widget timeout exceeded", test_results(:dashboard_failed).failure_message
  end

  test "formatted_status returns emoji string" do
    assert_equal "✅ PASSED", test_results(:login_passed).formatted_status
    assert_equal "❌ FAILED", test_results(:dashboard_failed).formatted_status
  end

  test "execution_time_ms converts to milliseconds" do
    assert_equal 1234, test_results(:login_passed).execution_time_ms
  end

  test "scope recent_failures returns failed results" do
    failures = TestResult.recent_failures
    assert_includes failures, test_results(:dashboard_failed)
    assert_not_includes failures, test_results(:login_passed)
  end

  test "scope by_suite filters correctly" do
    results = TestResult.by_suite(test_suites(:smoke_suite).id)
    assert_includes results, test_results(:login_passed)
    assert_includes results, test_results(:dashboard_failed)
  end

  test "scope by_status filters correctly" do
    passed = TestResult.by_status(:passed)
    assert_includes passed, test_results(:login_passed)
    assert_not_includes passed, test_results(:dashboard_failed)
  end

  test "class method success_rate returns percentage" do
    rate = TestResult.success_rate
    assert rate.is_a?(Float)
  end

  test "class method stats_overview returns hash" do
    stats = TestResult.stats_overview
    assert stats.key?(:total)
    assert stats.key?(:passed)
    assert stats.key?(:failed)
  end
end
