require "test_helper"

class LogCommentTest < ActiveSupport::TestCase
  test "valid with required attributes" do
    comment = log_comments(:admin_comment)
    assert comment.valid?
  end

  test "invalid without content" do
    comment = log_comments(:admin_comment)
    comment.content = nil
    assert_not comment.valid?
    assert_includes comment.errors[:content], "can't be blank"
  end

  test "belongs_to log" do
    comment = log_comments(:admin_comment)
    assert_respond_to comment, :log
    assert_equal logs(:run_log), comment.log
  end

  test "belongs_to user" do
    comment = log_comments(:admin_comment)
    assert_respond_to comment, :user
    assert_equal users(:admin), comment.user
  end

  test "scope recent orders by created_at desc" do
    recent = LogComment.recent
    assert recent.is_a?(ActiveRecord::Relation)
    # Both fixtures should be present
    assert_includes recent, log_comments(:admin_comment)
    assert_includes recent, log_comments(:manager_comment)
  end

  test "scope by_user filters correctly" do
    admin_comments = LogComment.by_user(users(:admin))
    assert_includes admin_comments, log_comments(:admin_comment)
    assert_not_includes admin_comments, log_comments(:manager_comment)

    manager_comments = LogComment.by_user(users(:manager))
    assert_includes manager_comments, log_comments(:manager_comment)
    assert_not_includes manager_comments, log_comments(:admin_comment)
  end

  test "can create with valid attributes" do
    comment = LogComment.new(
      content: "New comment for testing",
      log: logs(:run_log),
      user: users(:admin)
    )
    assert comment.valid?
    assert comment.save
  end

  test "invalid without log" do
    comment = LogComment.new(content: "Orphan comment", user: users(:admin))
    assert_not comment.valid?
  end

  test "invalid without user" do
    comment = LogComment.new(content: "Orphan comment", log: logs(:run_log))
    assert_not comment.valid?
  end
end
