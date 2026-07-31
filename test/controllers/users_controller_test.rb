require "test_helper"

class UsersControllerTest < ActionDispatch::IntegrationTest
  setup do
    post login_url, params: { email: "admin@ratf.test", password: "password" }
  end

  test "should get index" do
    get users_url
    assert_response :success
  end

  test "should get show" do
    user = users(:admin)
    get user_url(user)
    assert_response :success
  end

  test "should get new" do
    get new_user_url
    assert_response :success
  end

  test "should create user" do
    assert_difference("User.count") do
      post users_url, params: { user: { email: "new@example.com", username: "newuser", password: "password123", password_confirmation: "password123" } }
    end
    assert_redirected_to user_url(User.last)
    assert_equal "User created.", flash[:notice]
  end

  test "should not create user with invalid params" do
    post users_url, params: { user: { email: "" } }
    assert_response :unprocessable_entity
  end

  test "should get edit" do
    user = users(:admin)
    get edit_user_url(user)
    assert_response :success
  end

  test "should update user" do
    user = users(:admin)
    patch user_url(user), params: { user: { username: "updateduser" } }
    assert_redirected_to user_url(user)
    assert_equal "User updated.", flash[:notice]
  end

  test "should not update user with invalid params" do
    user = users(:admin)
    patch user_url(user), params: { user: { email: "" } }
    assert_response :unprocessable_entity
  end

  test "should destroy user" do
    user = User.create!(email: "temp-delete@example.com", username: "tempdelete", password: "password123", password_confirmation: "password123")
    assert_difference("User.count", -1) do
      delete user_url(user)
    end
    assert_redirected_to users_url
    assert_equal "User removed.", flash[:notice]
  end
end
