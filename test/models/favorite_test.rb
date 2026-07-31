require "test_helper"

class FavoriteTest < ActiveSupport::TestCase
  test "valid with required attributes" do
    favorite = favorites(:admin_fav_login)
    assert favorite.valid?
  end

  test "belongs_to user" do
    favorite = favorites(:admin_fav_login)
    assert_respond_to favorite, :user
    assert_equal users(:admin), favorite.user
  end

  test "belongs_to test_case" do
    favorite = favorites(:admin_fav_login)
    assert_respond_to favorite, :test_case
    assert_equal test_cases(:login_test), favorite.test_case
  end

  test "invalid without user" do
    favorite = Favorite.new(test_case: test_cases(:login_test))
    assert_not favorite.valid?
  end

  test "invalid without test_case" do
    favorite = Favorite.new(user: users(:admin))
    assert_not favorite.valid?
  end

  test "invalid with duplicate user_id and test_case_id" do
    existing = favorites(:admin_fav_login)
    duplicate = Favorite.new(user: existing.user, test_case: existing.test_case)
    assert_not duplicate.valid?
    assert_includes duplicate.errors[:user_id], "has already been taken"
  end

  test "scope for_user returns only that user's favorites" do
    admin_favs = Favorite.for_user(users(:admin))
    assert_includes admin_favs, favorites(:admin_fav_login)
    assert_includes admin_favs, favorites(:admin_fav_dashboard)
    assert_not_includes admin_favs, favorites(:manager_fav_api)
  end

  test "can create favorite for different test_case same user" do
    fav = Favorite.new(user: users(:admin), test_case: test_cases(:deprecated_test))
    assert fav.valid?
  end

  test "can create favorite for same test_case different user" do
    fav = Favorite.new(user: users(:manager), test_case: test_cases(:login_test))
    assert fav.valid?
  end
end
