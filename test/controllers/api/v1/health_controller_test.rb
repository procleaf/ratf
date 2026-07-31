require "test_helper"

class Api::V1::HealthControllerTest < ActionDispatch::IntegrationTest
  test "should get health check without authentication" do
    get api_v1_health_url
    assert_response :success
    body = JSON.parse(response.body)
    assert_includes %w[healthy degraded], body["status"]
    assert_equal "1.0.0", body["version"]
    assert body.key?("timestamp")
    assert body.key?("jobs_running")
  end

  test "health response is JSON" do
    get api_v1_health_url
    assert_response :success
    assert_equal "application/json; charset=utf-8", response.content_type
  end
end
