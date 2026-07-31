require "test_helper"

class TestCaseTest < ActiveSupport::TestCase
  test "valid with required attributes" do
    tc = test_cases(:login_test)
    assert tc.valid?
  end

  test "invalid without name" do
    tc = test_cases(:login_test)
    tc.name = nil
    assert_not tc.valid?
    assert_includes tc.errors[:name], "can't be blank"
  end

  test "invalid without test_type" do
    tc = test_cases(:login_test)
    tc.test_type = nil
    assert_not tc.valid?
    assert_includes tc.errors[:test_type], "can't be blank"
  end

  test "invalid with duplicate name in same test_suite" do
    existing = test_cases(:login_test)
    dup = TestCase.new(
      name: existing.name,
      test_suite: existing.test_suite,
      test_type: :functional,
      created_by: users(:admin)
    )
    assert_not dup.valid?
    assert_includes dup.errors[:name], "has already been taken"
  end

  test "enum status has correct values" do
    expected = { "draft" => 0, "active" => 1, "deprecated" => 2, "archived" => 3 }
    assert_equal expected, TestCase.statuses
  end

  test "enum priority has correct values" do
    expected = { "low" => 0, "medium" => 1, "high" => 2, "critical" => 3 }
    assert_equal expected, TestCase.priorities
  end

  test "enum test_type has correct values" do
    expected = { "functional" => 0, "performance" => 1, "security" => 2, "integration" => 3, "acceptance" => 4, "browser" => 5, "mobile" => 6, "natural_language" => 7 }
    assert_equal expected, TestCase.test_types
  end

  test "belongs_to test_suite" do
    tc = test_cases(:login_test)
    assert_respond_to tc, :test_suite
    assert_equal test_suites(:smoke_suite), tc.test_suite
  end

  test "belongs_to created_by" do
    tc = test_cases(:login_test)
    assert_respond_to tc, :created_by
    assert_equal users(:admin), tc.created_by
  end

  test "has_many test_results" do
    tc = test_cases(:login_test)
    assert_respond_to tc, :test_results
  end

  test "has_many tags through test_case_tags" do
    tc = test_cases(:login_test)
    assert_respond_to tc, :tags
    assert_equal 2, tc.tags.count
  end

  test "scope active_test_cases returns active only" do
    active = TestCase.active_test_cases
    assert_includes active, test_cases(:login_test)
    assert_not_includes active, test_cases(:deprecated_test)
  end

  test "scope by_priority filters correctly" do
    high = TestCase.by_priority(:high)
    assert_includes high, test_cases(:login_test)
  end

  test "scope by_tag filters by tag name" do
    results = TestCase.by_tag("smoke")
    assert_includes results, test_cases(:login_test)
    assert_includes results, test_cases(:dashboard_test)
  end

  test "success_rate computes correctly" do
    tc = test_cases(:login_test)
    rate = tc.success_rate
    assert_equal 100.0, rate
  end

  test "last_execution returns most recent result" do
    tc = test_cases(:login_test)
    result = tc.last_execution
    assert_equal test_results(:login_passed), result
  end

  test "flaky? returns false with few results" do
    tc = test_cases(:login_test)
    assert_not tc.flaky?
  end

  test "human_readable_status returns display string" do
    assert_equal "Active", test_cases(:login_test).human_readable_status
    assert_equal "Deprecated", test_cases(:deprecated_test).human_readable_status
  end

  test "to_yaml returns string" do
    yaml = test_cases(:login_test).to_yaml
    assert yaml.is_a?(String)
    assert_includes yaml, "Login Flow"
  end
end
