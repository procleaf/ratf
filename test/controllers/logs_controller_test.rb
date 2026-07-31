require "test_helper"

class LogsControllerTest < ActionDispatch::IntegrationTest
  setup do
    post login_url, params: { email: "admin@ratf.test", password: "password" }
  end

  test "should get index" do
    get logs_url
    assert_response :success
  end

  test "should get show" do
    log = logs(:run_log)
    get log_url(log)
    assert_response :success
  end

  test "should not route to new" do
    assert_raises(ActionController::RoutingError) do
      get "/logs/new"
    end
  end

  test "should not route to create" do
    assert_raises(ActionController::RoutingError) do
      post "/logs"
    end
  end

  test "should not route to edit" do
    assert_raises(ActionController::RoutingError) do
      get "/logs/1/edit"
    end
  end

  test "should not route to update" do
    assert_raises(ActionController::RoutingError) do
      patch "/logs/1"
    end
  end

  test "should not route to destroy" do
    assert_raises(ActionController::RoutingError) do
      delete "/logs/1"
    end
  end
end
