require "test_helper"

class IssueCommentTest < ActiveSupport::TestCase
  test "valid with required attributes" do
    comment = issue_comments(:comment_one)
    assert comment.valid?
  end

  test "invalid without content" do
    comment = issue_comments(:comment_one)
    comment.content = nil
    assert_not comment.valid?
    assert_includes comment.errors[:content], "can't be blank"
  end

  test "belongs_to issue" do
    comment = issue_comments(:comment_one)
    assert_respond_to comment, :issue
    assert_equal issues(:open_bug), comment.issue
  end

  test "belongs_to user" do
    comment = issue_comments(:comment_one)
    assert_respond_to comment, :user
    assert_equal users(:admin), comment.user
  end

  test "scope chronological returns ordered by created_at asc" do
    comments = IssueComment.chronological
    assert comments.is_a?(ActiveRecord::Relation)
    assert comments.first.created_at <= comments.last.created_at
  end
end
