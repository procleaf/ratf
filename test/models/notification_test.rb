require "test_helper"

class NotificationTest < ActiveSupport::TestCase
  test "valid with required attributes" do
    notification = notifications(:job_completed_note)
    assert notification.valid?
  end

  test "invalid without message" do
    notification = notifications(:job_completed_note)
    notification.message = nil
    assert_not notification.valid?
    assert_includes notification.errors[:message], "can't be blank"
  end

  test "invalid without notification_type" do
    notification = notifications(:job_completed_note)
    notification.notification_type = nil
    assert_not notification.valid?
    assert_includes notification.errors[:notification_type], "can't be blank"
  end

  test "enum notification_type has correct values" do
    expected = {
      "issue_assignment" => 0, "issue_comment" => 1,
      "job_completed" => 2, "job_failed" => 3,
      "test_failure" => 4, "system" => 5
    }
    assert_equal expected, Notification.notification_types
  end

  test "belongs_to user" do
    notification = notifications(:job_completed_note)
    assert_respond_to notification, :user
    assert_equal users(:admin), notification.user
  end

  test "scope unread returns notifications without read_at" do
    unread = Notification.unread
    assert_includes unread, notifications(:issue_assignment_note)
    assert_includes unread, notifications(:unread_note)
  end

  test "scope recent returns ordered by created_at desc" do
    recent = Notification.recent
    assert recent.is_a?(ActiveRecord::Relation)
  end

  test "mark_as_read! sets read_at" do
    notification = notifications(:unread_note)
    notification.mark_as_read!
    assert notification.read?
    assert_not_nil notification.read_at
  end

  test "read? returns false for unread" do
    assert_not notifications(:unread_note).read?
  end

  test "read? returns true after mark_as_read!" do
    notification = notifications(:unread_note)
    notification.mark_as_read!
    assert notification.read?
  end
end
