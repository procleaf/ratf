require "test_helper"

class CloudProvidersControllerTest < ActionDispatch::IntegrationTest
  setup do
    post login_url, params: { email: "admin@ratf.test", password: "password" }
  end

  test "should get index" do
    get cloud_providers_url
    assert_response :success
  end

  test "should get show" do
    provider = cloud_providers(:aws_provider)
    get cloud_provider_url(provider)
    assert_response :success
  end

  test "should get new" do
    get new_cloud_provider_url
    assert_response :success
  end

  test "should create cloud_provider" do
    assert_difference("CloudProvider.count") do
      post cloud_providers_url, params: { cloud_provider: { name: "New Provider", provider_type: "aws", region: "us-west-2", enabled: true } }
    end
    assert_redirected_to cloud_provider_url(CloudProvider.last)
    assert_equal "Provider created.", flash[:notice]
  end

  test "should not create cloud_provider with invalid params" do
    post cloud_providers_url, params: { cloud_provider: { name: "" } }
    assert_response :unprocessable_entity
  end

  test "should get edit" do
    provider = cloud_providers(:aws_provider)
    get edit_cloud_provider_url(provider)
    assert_response :success
  end

  test "should update cloud_provider" do
    provider = cloud_providers(:aws_provider)
    patch cloud_provider_url(provider), params: { cloud_provider: { name: "Updated AWS" } }
    assert_redirected_to cloud_provider_url(provider)
    assert_equal "Provider updated.", flash[:notice]
  end

  test "should not update cloud_provider with invalid params" do
    provider = cloud_providers(:aws_provider)
    patch cloud_provider_url(provider), params: { cloud_provider: { name: "" } }
    assert_response :unprocessable_entity
  end

  test "should destroy cloud_provider without instances" do
    provider = cloud_providers(:azure_provider)
    assert_difference("CloudProvider.count", -1) do
      delete cloud_provider_url(provider)
    end
    assert_redirected_to cloud_providers_url
    assert_equal "Provider deleted.", flash[:notice]
  end

  test "should verify cloud_provider" do
    provider = cloud_providers(:aws_provider)
    post verify_cloud_provider_url(provider)
    assert_redirected_to cloud_provider_url(provider)
    assert_includes ["Connection verified.", "Connection failed."], flash[:notice]
  end

  test "should require authentication" do
    delete logout_url
    get cloud_providers_url
    assert_redirected_to login_path
  end
end
