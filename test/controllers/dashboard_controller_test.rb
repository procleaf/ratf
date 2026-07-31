require "test_helper"

class DashboardControllerTest < ActionDispatch::IntegrationTest
  setup do
    post login_url, params: { email: "admin@ratf.test", password: "password" }
  end

  test "should get index at root url" do
    get root_url
    assert_response :success
  end

  test "should get index at dashboard path" do
    get "/dashboard"
    assert_response :success
  end
end
