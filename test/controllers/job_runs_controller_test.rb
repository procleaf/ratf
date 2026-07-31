require "test_helper"

class JobRunsControllerTest < ActionDispatch::IntegrationTest
  setup do
    post login_url, params: { email: "admin@ratf.test", password: "password" }
  end

  test "should get index" do
    get job_runs_url
    assert_response :success
  end

  test "should get show" do
    job_run = job_runs(:pending_run)
    get job_run_url(job_run)
    assert_response :success
  end

  test "should not route to new" do
    assert_raises(ActionController::RoutingError) do
      get "/job_runs/new"
    end
  end

  test "should not route to create" do
    assert_raises(ActionController::RoutingError) do
      post "/job_runs"
    end
  end

  test "should not route to edit" do
    assert_raises(ActionController::RoutingError) do
      get "/job_runs/1/edit"
    end
  end

  test "should not route to update" do
    assert_raises(ActionController::RoutingError) do
      patch "/job_runs/1"
    end
  end

  test "should not route to destroy" do
    assert_raises(ActionController::RoutingError) do
      delete "/job_runs/1"
    end
  end
end
