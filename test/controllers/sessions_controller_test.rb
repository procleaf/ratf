require "test_helper"

class SessionsControllerTest < ActionDispatch::IntegrationTest
  test "should get login page" do
    get login_url
    assert_response :success
  end

  test "should login with valid credentials" do
    post login_url, params: { email: "admin@ratf.test", password: "password" }
    assert_redirected_to root_path
    assert_equal "Welcome back, admin!", flash[:notice]
    assert session[:user_id].present?
  end

  test "should not login with invalid password" do
    post login_url, params: { email: "admin@ratf.test", password: "wrongpassword" }
    assert_response :unprocessable_entity
    # flash.now[:alert] is set — check response body for the alert message
    assert_match(/Invalid email or password/, response.body)
  end

  test "should not login with non-existent email" do
    post login_url, params: { email: "nonexistent@ratf.test", password: "password" }
    assert_response :unprocessable_entity
    assert_match(/Invalid email or password/, response.body)
  end

  test "should not login with blank credentials" do
    post login_url, params: { email: "", password: "" }
    assert_response :unprocessable_entity
  end

  test "should logout" do
    post login_url, params: { email: "admin@ratf.test", password: "password" }
    assert session[:user_id].present?

    delete logout_url
    assert_redirected_to login_path
    assert_equal "Logged out.", flash[:notice]
    # After logout, session user_id should be nil
    get root_url
    assert_redirected_to login_path
  end

  test "should redirect to root if already logged in" do
    post login_url, params: { email: "admin@ratf.test", password: "password" }
    get login_url
    assert_redirected_to root_path
  end
end
