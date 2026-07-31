require "test_helper"

class IssueAttachmentTest < ActiveSupport::TestCase
  test "valid with required attributes" do
    # IssueAttachment validates presence of file (ActiveStorage attachment)
    # Fixture testing is limited without actual file attachment
    attachment = IssueAttachment.new(issue: issues(:open_bug))
    # Without file blob attached, will be invalid
    assert_not attachment.valid?
    assert_includes attachment.errors[:file], "can't be blank"
  end

  test "belongs_to issue" do
    attachment = issue_attachments(:attachment_one)
    assert_respond_to attachment, :issue
    assert_equal issues(:open_bug), attachment.issue
  end
end
