require "test_helper"

class TestSuiteTest < ActiveSupport::TestCase
  test "valid with required attributes" do
    suite = test_suites(:smoke_suite)
    assert suite.valid?
  end

  test "invalid without name" do
    suite = test_suites(:smoke_suite)
    suite.name = nil
    assert_not suite.valid?
    assert_includes suite.errors[:name], "can't be blank"
  end

  test "valid version format" do
    suite = test_suites(:smoke_suite)
    suite.version = "1.0.0"
    assert suite.valid?
  end

  test "invalid version format" do
    suite = test_suites(:smoke_suite)
    suite.version = "not-a-version"
    assert_not suite.valid?
    assert_includes suite.errors[:version], "is invalid"
  end

  test "blank version is allowed" do
    suite = test_suites(:smoke_suite)
    suite.version = ""
    assert suite.valid?
  end

  test "enum status has correct values" do
    expected = { "active" => 0, "maintenance" => 1, "deprecated" => 2 }
    assert_equal expected, TestSuite.statuses
  end

  test "belongs_to project optional" do
    suite = test_suites(:smoke_suite)
    assert_respond_to suite, :project
    assert_equal projects(:active_project), suite.project
  end

  test "has_many test_cases" do
    suite = test_suites(:smoke_suite)
    assert_respond_to suite, :test_cases
    assert_equal 2, suite.test_cases.count
  end

  test "has_many test_suite_runs" do
    suite = test_suites(:smoke_suite)
    assert_respond_to suite, :test_suite_runs
  end

  test "scope by_tag finds matching" do
    results = TestSuite.by_tag("smoke")
    assert_includes results, test_suites(:smoke_suite)
  end

  test "total_test_cases counts active cases" do
    suite = test_suites(:smoke_suite)
    assert_equal 2, suite.total_test_cases
  end

  test "last_run returns most recent suite run" do
    suite = test_suites(:smoke_suite)
    run = suite.last_run
    assert_equal test_suite_runs(:smoke_suite_run), run
  end

  test "to_yaml returns hash" do
    suite = test_suites(:smoke_suite)
    yaml = suite.to_yaml
    assert yaml.is_a?(String)
    assert_includes yaml, "Smoke Tests"
  end
end
