require "test_helper"

class IssueCommentsControllerTest < ActionDispatch::IntegrationTest
  setup do
    post login_url, params: { email: "admin@ratf.test", password: "password" }
    @issue = issues(:open_bug)
  end

  test "should get index" do
    get issue_issue_comments_url(@issue)
    assert_response :success
  end

  test "should get show" do
    comment = issue_comments(:comment_one)
    get issue_issue_comment_url(@issue, comment)
    assert_response :success
  end

  test "should get new" do
    get new_issue_issue_comment_url(@issue)
    assert_response :success
  end

  test "should create issue_comment" do
    assert_difference("IssueComment.count") do
      post issue_issue_comments_url(@issue), params: { issue_comment: { content: "A new comment" } }
    end
    assert_redirected_to issue_issue_comment_url(@issue, IssueComment.last)
  end

  test "should not create issue_comment with invalid params" do
    post issue_issue_comments_url(@issue), params: { issue_comment: { content: "" } }
    assert_response :unprocessable_entity
  end

  test "should get edit" do
    comment = issue_comments(:comment_one)
    get edit_issue_issue_comment_url(@issue, comment)
    assert_response :success
  end

  test "should update issue_comment" do
    comment = issue_comments(:comment_one)
    patch issue_issue_comment_url(@issue, comment), params: { issue_comment: { content: "Updated content" } }
    assert_redirected_to issue_issue_comment_url(@issue, comment)
  end

  test "should not update issue_comment with invalid params" do
    comment = issue_comments(:comment_one)
    patch issue_issue_comment_url(@issue, comment), params: { issue_comment: { content: "" } }
    assert_response :unprocessable_entity
  end

  test "should destroy issue_comment" do
    comment = issue_comments(:comment_one)
    assert_difference("IssueComment.count", -1) do
      delete issue_issue_comment_url(@issue, comment)
    end
    assert_redirected_to issue_url(@issue)
  end
end
