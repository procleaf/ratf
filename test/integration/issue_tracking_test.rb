require "test_helper"

class IssueTrackingTest < ActionDispatch::IntegrationTest
  setup do
    post login_url, params: { email: "admin@ratf.test", password: "password" }
    @user = users(:admin)
    @assignee = users(:user_one)
  end

  test "should create an issue and view its detail page" do
    get new_issue_path
    assert_response :success
    assert_select "h1", "New Issue"
    assert_select "form"

    assert_difference("Issue.count", 1) do
      post issues_path, params: {
        issue: {
          title: "Login page timeout on slow connections",
          description: "Users on 2G connections cannot login within the timeout window.",
          status: "open",
          severity: "major",
          urgency: "high",
          issue_type: "bug",
          assigned_to_id: @assignee.id
        }
      }
    end

    assert_redirected_to issue_path(Issue.last)
    follow_redirect!
    assert_response :success
    assert_select "h1", "Login page timeout on slow connections"
    assert_select "dd", /Users on 2G connections/
    assert_select "dd", "Open"
    assert_select "dd", "Major"
    assert_select "dd", "High"
    assert_select "dd", /user1/
  end

  test "should add a comment to an issue" do
    issue = Issue.create!(
      title: "Issue with comments",
      description: "Testing comment workflow",
      reported_by: @user,
      status: :open,
      severity: :minor,
      urgency: :medium,
      issue_type: :bug
    )

    get issue_path(issue)
    assert_response :success
    assert_select "a", "Add Comment"

    get new_issue_issue_comment_path(issue)
    assert_response :success
    assert_select "h1", "New Comment"
    assert_select "form"

    assert_difference("IssueComment.count", 1) do
      post issue_issue_comments_path(issue), params: {
        issue_comment: {
          content: "I can reproduce this on Firefox 130."
        }
      }
    end

    assert_redirected_to issue_issue_comment_path(issue, IssueComment.last)
    follow_redirect!
    assert_response :success
    assert_select "dd", /I can reproduce this on Firefox 130/
    assert_select "dd", "admin"

    # Return to issue page — the comment should be visible there too
    get issue_path(issue)
    assert_response :success
    assert_select ".comment", /I can reproduce this on Firefox 130/
    assert_select ".comment", /admin/
  end

  test "should change issue status through update" do
    issue = Issue.create!(
      title: "Status Change Test",
      description: "Testing status transitions",
      reported_by: @user,
      status: :open,
      severity: :minor,
      urgency: :low,
      issue_type: :enhancement
    )

    get edit_issue_path(issue)
    assert_response :success
    assert_select "h1", "Edit Issue"
    assert_select "form"

    patch issue_path(issue), params: {
      issue: {
        title: issue.title,
        description: issue.description,
        status: "in_progress",
        severity: "minor",
        urgency: "low",
        issue_type: "enhancement"
      }
    }

    assert_redirected_to issue_path(issue)
    follow_redirect!
    assert_response :success
    assert_select "dd", "In Progress"
  end

  test "should close an issue" do
    issue = Issue.create!(
      title: "Issue To Close",
      description: "This issue will be closed",
      reported_by: @user,
      status: :open,
      severity: :trivial,
      urgency: :low,
      issue_type: :bug
    )

    patch issue_path(issue), params: {
      issue: {
        title: issue.title,
        description: issue.description,
        status: "closed",
        severity: "trivial",
        urgency: "low",
        issue_type: "bug"
      }
    }

    assert_redirected_to issue_path(issue)
    follow_redirect!
    assert_response :success
    assert_select "dd", "Closed"
  end

  test "should show validation errors when creating issue without title" do
    get new_issue_path
    assert_response :success

    post issues_path, params: {
      issue: {
        title: "",
        description: "No title provided",
        status: "open",
        severity: "minor",
        urgency: "low",
        issue_type: "bug"
      }
    }

    assert_response :unprocessable_entity
    assert_select ".errors" do
      assert_select "li", /Title can't be blank/
    end
  end
end
