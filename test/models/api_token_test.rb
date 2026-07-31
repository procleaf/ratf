require "test_helper"

class ApiTokenTest < ActiveSupport::TestCase
  test "valid with required attributes" do
    token = api_tokens(:admin_token)
    assert token.valid?
  end

  test "invalid without name" do
    token = api_tokens(:admin_token)
    token.name = nil
    assert_not token.valid?
    assert_includes token.errors[:name], "can't be blank"
  end

  test "belongs_to user" do
    token = api_tokens(:admin_token)
    assert_respond_to token, :user
    assert_equal users(:admin), token.user
  end

  test "generates token on create" do
    token = ApiToken.new(name: "Test Token", user: users(:admin))
    token.save!
    assert_not_nil token.token_digest
    assert_not_nil token.raw_token
  end

  test "raw_token is accessible after create" do
    token = ApiToken.new(name: "Access Token", user: users(:admin))
    token.save!
    assert token.raw_token.present?
    assert_equal 64, token.raw_token.length
  end

  test "expired? returns false when no expiration set" do
    token = api_tokens(:admin_token)
    assert_not token.expired?
  end

  test "expired? returns false when not yet expired" do
    token = api_tokens(:manager_token)
    assert_not token.expired?
  end

  test "expired? returns true when expired" do
    token = api_tokens(:admin_token)
    token.expires_at = 1.day.ago
    assert token.expired?
  end

  test "scope active excludes expired tokens" do
    # Create expired token
    ApiToken.create!(name: "Expired", user: users(:admin), expires_at: 1.day.ago)
    active = ApiToken.active
    assert_includes active, api_tokens(:admin_token)
    # The expired token should not be in active
    expired = ApiToken.where(name: "Expired")
    expired.each { |t| assert_not_includes active, t }
  end

  test "record_usage! updates last_used_at" do
    token = api_tokens(:admin_token)
    token.record_usage!
    assert_not_nil token.last_used_at
  end
end
