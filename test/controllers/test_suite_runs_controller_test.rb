require "test_helper"

class TestSuiteRunsControllerTest < ActionDispatch::IntegrationTest
  setup do
    post login_url, params: { email: "admin@ratf.test", password: "password" }
  end

  test "should get index" do
    get test_suite_runs_url
    assert_response :success
  end

  test "should get show" do
    test_suite_run = test_suite_runs(:smoke_suite_run)
    get test_suite_run_url(test_suite_run)
    assert_response :success
  end

  test "should not route to new" do
    assert_raises(ActionController::RoutingError) do
      get "/test_suite_runs/new"
    end
  end

  test "should not route to create" do
    assert_raises(ActionController::RoutingError) do
      post "/test_suite_runs"
    end
  end

  test "should not route to edit" do
    assert_raises(ActionController::RoutingError) do
      get "/test_suite_runs/1/edit"
    end
  end

  test "should not route to update" do
    assert_raises(ActionController::RoutingError) do
      patch "/test_suite_runs/1"
    end
  end

  test "should not route to destroy" do
    assert_raises(ActionController::RoutingError) do
      delete "/test_suite_runs/1"
    end
  end
end
