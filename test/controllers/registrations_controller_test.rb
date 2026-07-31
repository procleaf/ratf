require "test_helper"

class RegistrationsControllerTest < ActionDispatch::IntegrationTest
  test "should get registration page" do
    get register_url
    assert_response :success
  end

  test "should create user with valid params" do
    assert_difference("User.count") do
      post register_url, params: { user: { email: "newuser@ratf.test", username: "newuser", password: "password123", password_confirmation: "password123" } }
    end
    assert_redirected_to root_path
    assert_equal "Welcome to RATF, newuser!", flash[:notice]
    assert session[:user_id].present?
  end

  test "should not create user with invalid params" do
    assert_no_difference("User.count") do
      post register_url, params: { user: { email: "", username: "", password: "", password_confirmation: "" } }
    end
    assert_response :unprocessable_entity
  end

  test "should not create user with duplicate email" do
    assert_no_difference("User.count") do
      post register_url, params: { user: { email: "admin@ratf.test", username: "unique_user", password: "password123", password_confirmation: "password123" } }
    end
    assert_response :unprocessable_entity
  end

  test "should not create user with duplicate username" do
    assert_no_difference("User.count") do
      post register_url, params: { user: { email: "unique@ratf.test", username: "admin", password: "password123", password_confirmation: "password123" } }
    end
    assert_response :unprocessable_entity
  end

  test "should not create user with mismatched password confirmation" do
    assert_no_difference("User.count") do
      post register_url, params: { user: { email: "mismatch@ratf.test", username: "mismatch", password: "password123", password_confirmation: "different" } }
    end
    assert_response :unprocessable_entity
  end
end
