require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "valid with required attributes" do
    user = users(:admin)
    assert user.valid?
  end

  test "invalid without email" do
    user = users(:admin)
    user.email = nil
    assert_not user.valid?
    assert_includes user.errors[:email], "can't be blank"
  end

  test "invalid without username" do
    user = users(:admin)
    user.username = nil
    assert_not user.valid?
    assert_includes user.errors[:username], "can't be blank"
  end

  test "invalid with duplicate email" do
    user = User.new(email: users(:admin).email, username: "unique_user", password: "password")
    assert_not user.valid?
    assert_includes user.errors[:email], "has already been taken"
  end

  test "invalid with duplicate username" do
    user = User.new(email: "unique@ratf.test", username: users(:admin).username, password: "password")
    assert_not user.valid?
    assert_includes user.errors[:username], "has already been taken"
  end

  test "invalid with bad email format" do
    user = User.new(email: "not-an-email", username: "bad_email_user", password: "password")
    assert_not user.valid?
    assert_includes user.errors[:email], "is invalid"
  end

  test "enum role has correct values" do
    assert_equal({ "user" => 0, "admin" => 1, "manager" => 2 }, User.roles)
    assert users(:admin).admin?
    assert users(:manager).manager?
    assert users(:user_one).user?
  end

  test "has_many jobs" do
    user = users(:admin)
    assert_respond_to user, :jobs
  end

  test "has_many notifications" do
    user = users(:admin)
    assert_respond_to user, :notifications
  end

  test "active? returns true when recently active" do
    user = users(:admin)
    assert user.active?
  end

  test "active? returns false when inactive" do
    user = users(:user_two)
    assert_not user.active?
  end

  test "total_jobs_run counts completed jobs" do
    user = users(:user_one)
    assert_equal 1, user.total_jobs_run
  end

  test "success_rate computes correctly" do
    user = users(:user_one)
    rate = user.job_success_rate
    assert_equal 100.0, rate
  end
end
