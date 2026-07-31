require "test_helper"

class UserSubscriptionTest < ActiveSupport::TestCase
  test "valid with required attributes" do
    sub = user_subscriptions(:admin_sub_open)
    assert sub.valid?
  end

  test "invalid with duplicate user and issue" do
    existing = user_subscriptions(:admin_sub_open)
    dup = UserSubscription.new(user: existing.user, issue: existing.issue)
    assert_not dup.valid?
    assert_includes dup.errors[:user_id], "has already been taken"
  end

  test "belongs_to user" do
    sub = user_subscriptions(:admin_sub_open)
    assert_respond_to sub, :user
    assert_equal users(:admin), sub.user
  end

  test "belongs_to issue" do
    sub = user_subscriptions(:admin_sub_open)
    assert_respond_to sub, :issue
    assert_equal issues(:open_bug), sub.issue
  end
end
