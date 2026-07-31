require "test_helper"

class TestResultsControllerTest < ActionDispatch::IntegrationTest
  setup do
    post login_url, params: { email: "admin@ratf.test", password: "password" }
  end

  test "should get index" do
    get test_results_url
    assert_response :success
  end

  test "should get show" do
    test_result = test_results(:login_passed)
    get test_result_url(test_result)
    assert_response :success
  end

  test "should not route to new" do
    assert_raises(ActionController::RoutingError) do
      get "/test_results/new"
    end
  end

  test "should not route to create" do
    assert_raises(ActionController::RoutingError) do
      post "/test_results"
    end
  end

  test "should not route to edit" do
    assert_raises(ActionController::RoutingError) do
      get "/test_results/1/edit"
    end
  end

  test "should not route to update" do
    assert_raises(ActionController::RoutingError) do
      patch "/test_results/1"
    end
  end

  test "should not route to destroy" do
    assert_raises(ActionController::RoutingError) do
      delete "/test_results/1"
    end
  end
end
