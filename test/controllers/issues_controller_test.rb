require "test_helper"

class IssuesControllerTest < ActionDispatch::IntegrationTest
  setup do
    post login_url, params: { email: "admin@ratf.test", password: "password" }
  end

  test "should get index" do
    get issues_url
    assert_response :success
  end

  test "should get show" do
    issue = issues(:open_bug)
    get issue_url(issue)
    assert_response :success
  end

  test "should get new" do
    get new_issue_url
    assert_response :success
  end

  test "should create issue" do
    assert_difference("Issue.count") do
      post issues_url, params: { issue: { title: "New Issue", description: "A test issue", status: "open", severity: "minor", urgency: "low", issue_type: "bug" } }
    end
    assert_redirected_to issue_url(Issue.last)
    assert_equal "Issue was successfully created.", flash[:notice]
  end

  test "should not create issue with invalid params" do
    post issues_url, params: { issue: { title: "" } }
    assert_response :unprocessable_entity
  end

  test "should get edit" do
    issue = issues(:open_bug)
    get edit_issue_url(issue)
    assert_response :success
  end

  test "should update issue" do
    issue = issues(:open_bug)
    patch issue_url(issue), params: { issue: { title: "Updated Issue" } }
    assert_redirected_to issue_url(issue)
    assert_equal "Issue was successfully updated.", flash[:notice]
  end

  test "should not update issue with invalid params" do
    issue = issues(:open_bug)
    patch issue_url(issue), params: { issue: { title: "" } }
    assert_response :unprocessable_entity
  end

  test "should destroy issue" do
    issue = Issue.create!(title: "temp-issue-delete", description: "To be deleted", reported_by: users(:admin))
    assert_difference("Issue.count", -1) do
      delete issue_url(issue)
    end
    assert_redirected_to issues_url
    assert_equal "Issue was successfully deleted.", flash[:notice]
  end
end
