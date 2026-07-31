require "test_helper"

class NotificationsControllerTest < ActionDispatch::IntegrationTest
  setup do
    post login_url, params: { email: "admin@ratf.test", password: "password" }
  end

  test "should get index" do
    get notifications_url
    assert_response :success
  end

  test "should get show" do
    notification = notifications(:issue_assignment_note)
    get notification_url(notification)
    assert_response :success
  end

  test "should get new" do
    get new_notification_url
    assert_response :success
  end

  test "should create notification" do
    assert_difference("Notification.count") do
      post notifications_url, params: { notification: { user_id: users(:admin).id, message: "Test notification", notification_type: "system" } }
    end
    assert_redirected_to notification_url(Notification.last)
    assert_equal "Notification created.", flash[:notice]
  end

  test "should not create notification with invalid params" do
    post notifications_url, params: { notification: { message: "" } }
    assert_response :unprocessable_entity
  end

  test "should get edit" do
    notification = notifications(:issue_assignment_note)
    get edit_notification_url(notification)
    assert_response :success
  end

  test "should update notification" do
    notification = notifications(:issue_assignment_note)
    patch notification_url(notification), params: { notification: { message: "Updated notification" } }
    assert_redirected_to notification_url(notification)
    assert_equal "Notification updated.", flash[:notice]
  end

  test "should not update notification with invalid params" do
    notification = notifications(:issue_assignment_note)
    patch notification_url(notification), params: { notification: { message: "" } }
    assert_response :unprocessable_entity
  end

  test "should destroy notification" do
    notification = notifications(:issue_assignment_note)
    assert_difference("Notification.count", -1) do
      delete notification_url(notification)
    end
    assert_redirected_to notifications_url
    assert_equal "Notification removed.", flash[:notice]
  end

  test "should mark notification as read" do
    notification = notifications(:issue_assignment_note)
    post mark_read_notification_url(notification)
    assert_redirected_to notifications_url
    assert_equal "Notification marked as read.", flash[:notice]
  end
end
