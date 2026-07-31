require "test_helper"

class IssueTest < ActiveSupport::TestCase
  test "valid with required attributes" do
    issue = issues(:open_bug)
    assert issue.valid?
  end

  test "invalid without title" do
    issue = issues(:open_bug)
    issue.title = nil
    assert_not issue.valid?
    assert_includes issue.errors[:title], "can't be blank"
  end

  test "invalid without description" do
    issue = issues(:open_bug)
    issue.description = nil
    assert_not issue.valid?
    assert_includes issue.errors[:description], "can't be blank"
  end

  test "enum status has correct values" do
    expected = { "open" => 0, "in_progress" => 1, "resolved" => 2, "closed" => 3, "reopened" => 4 }
    assert_equal expected, Issue.statuses
  end

  test "enum severity has correct values" do
    expected = { "trivial" => 0, "minor" => 1, "major" => 2, "critical" => 3, "blocker" => 4 }
    assert_equal expected, Issue.severities
  end

  test "enum urgency has correct values" do
    expected = { "low" => 0, "medium" => 1, "high" => 2, "critical" => 3 }
    assert_equal expected, Issue.urgencies
  end

  test "enum issue_type has correct values" do
    expected = { "bug" => 0, "enhancement" => 1, "feature_request" => 2, "question" => 3, "technical_debt" => 4 }
    assert_equal expected, Issue.issue_types
  end

  test "belongs_to test_case optional" do
    issue = issues(:open_bug)
    assert_respond_to issue, :test_case
    assert_equal test_cases(:dashboard_test), issue.test_case
  end

  test "belongs_to test_result optional" do
    issue = issues(:open_bug)
    assert_respond_to issue, :test_result
    assert_equal test_results(:dashboard_failed), issue.test_result
  end

  test "belongs_to reported_by" do
    issue = issues(:open_bug)
    assert_respond_to issue, :reported_by
    assert_equal users(:admin), issue.reported_by
  end

  test "belongs_to assigned_to optional" do
    issue = issues(:open_bug)
    assert_respond_to issue, :assigned_to
    assert_equal users(:user_one), issue.assigned_to
  end

  test "has_many issue_comments" do
    issue = issues(:open_bug)
    assert_respond_to issue, :issue_comments
  end

  test "has_many issue_attachments" do
    issue = issues(:open_bug)
    assert_respond_to issue, :issue_attachments
  end

  test "scope open_issues returns non-closed issues" do
    open = Issue.open_issues
    assert_includes open, issues(:open_bug)
    assert_includes open, issues(:in_progress_issue)
    assert_not_includes open, issues(:resolved_issue)
  end

  test "scope by_severity filters correctly" do
    critical = Issue.by_severity(:critical)
    assert_includes critical, issues(:open_bug)
  end

  test "scope assigned_to_user filters correctly" do
    assigned = Issue.assigned_to_user(users(:user_one).id)
    assert_includes assigned, issues(:open_bug)
  end

  test "priority_score computes weighted sum" do
    score = issues(:open_bug).priority_score
    assert score > 0
  end

  test "can_close? returns false for open" do
    assert_not issues(:open_bug).can_close?
  end

  test "can_close? returns true for resolved" do
    assert issues(:resolved_issue).can_close?
  end

  test "time_open computes seconds" do
    time = issues(:resolved_issue).time_open
    assert time.is_a?(Float), "Expected Float, got #{time.class}"
    assert time > 0, "Expected positive, got #{time}"
  end

  test "formatted_time_open returns human readable" do
    formatted = issues(:resolved_issue).formatted_time_open
    assert_match(/\d+d \d+h \d+m/, formatted)
  end

  test "to_json_api returns hash" do
    json = issues(:open_bug).to_json_api
    assert json.key?(:title)
    assert json.key?(:status)
  end
end
