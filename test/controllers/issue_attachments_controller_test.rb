require "test_helper"

class IssueAttachmentsControllerTest < ActionDispatch::IntegrationTest
  setup do
    post login_url, params: { email: "admin@ratf.test", password: "password" }
    @issue = issues(:open_bug)
  end

  test "should get index" do
    get issue_issue_attachments_url(@issue)
    assert_response :success
  end

  test "should get show" do
    attachment = issue_attachments(:attachment_one)
    get issue_issue_attachment_url(@issue, attachment)
    assert_response :success
  end

  test "should get new" do
    get new_issue_issue_attachment_url(@issue)
    assert_response :success
  end

  test "should create issue_attachment" do
    assert_difference("IssueAttachment.count") do
      post issue_issue_attachments_url(@issue), params: { issue_attachment: { file: fixture_file_upload("test_attachment.txt", "text/plain") } }
    end
    assert_redirected_to issue_issue_attachment_url(@issue, IssueAttachment.last)
  end

  test "should not create issue_attachment with invalid params" do
    post issue_issue_attachments_url(@issue), params: { issue_attachment: { file: nil } }
    assert_response :unprocessable_entity
  end

  test "should get edit" do
    attachment = issue_attachments(:attachment_one)
    get edit_issue_issue_attachment_url(@issue, attachment)
    assert_response :success
  end

  test "should update issue_attachment" do
    attachment = issue_attachments(:attachment_one)
    patch issue_issue_attachment_url(@issue, attachment), params: { issue_attachment: { file: fixture_file_upload("test_attachment.txt", "text/plain") } }
    assert_redirected_to issue_issue_attachment_url(@issue, attachment)
  end

  test "should not update issue_attachment with invalid params" do
    attachment = issue_attachments(:attachment_one)
    patch issue_issue_attachment_url(@issue, attachment), params: { issue_attachment: { file: nil } }
    assert_response :unprocessable_entity
  end

  test "should destroy issue_attachment" do
    attachment = issue_attachments(:attachment_one)
    assert_difference("IssueAttachment.count", -1) do
      delete issue_issue_attachment_url(@issue, attachment)
    end
    assert_redirected_to issue_url(@issue)
  end
end
