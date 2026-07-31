require "test_helper"

class FavoritesControllerTest < ActionDispatch::IntegrationTest
  setup do
    post login_url, params: { email: "admin@ratf.test", password: "password" }
  end

  test "should get index" do
    get favorites_url
    assert_response :success
  end

  test "should create favorite" do
    test_case = test_cases(:deprecated_test)
    assert_difference("Favorite.count") do
      post favorites_url, params: { test_case_id: test_case.id }
    end
    assert_redirected_to test_cases_path
    assert_equal "Added to favorites.", flash[:notice]
  end

  test "should destroy favorite" do
    favorite = favorites(:admin_fav_dashboard)
    assert_difference("Favorite.count", -1) do
      delete favorite_url(favorite), params: { test_case_id: favorite.test_case_id }
    end
    assert_redirected_to test_cases_path
    assert_equal "Removed from favorites.", flash[:notice]
  end

  test "should toggle favorite on" do
    # toggle uses a member route requiring an :id in the URL;
    # we pass any existing favorite id as the URL anchor and
    # the target test_case_id as a query param.
    anchor_fav = favorites(:admin_fav_login)
    test_case = test_cases(:deprecated_test)
    assert_difference("Favorite.count") do
      post toggle_favorite_url(anchor_fav, test_case_id: test_case.id)
    end
    assert_redirected_to test_cases_path
    assert_equal "Added to favorites.", flash[:notice]
  end

  test "should toggle favorite off" do
    favorite = favorites(:admin_fav_dashboard)
    assert_difference("Favorite.count", -1) do
      post toggle_favorite_url(favorite, test_case_id: favorite.test_case_id)
    end
    assert_redirected_to test_cases_path
    assert_equal "Removed from favorites.", flash[:notice]
  end

  test "should handle missing test_case gracefully" do
    post favorites_url, params: { test_case_id: 99999 }
    assert_redirected_to test_cases_path
    assert_equal "Test case not found.", flash[:alert]
  end

  test "should require authentication" do
    delete logout_url
    get favorites_url
    assert_redirected_to login_path
  end
end
