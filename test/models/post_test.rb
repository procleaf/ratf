require "test_helper"

class PostTest < ActiveSupport::TestCase
  test "valid with required attributes" do
    post = posts(:post_one)
    assert post.valid?
  end

  test "belongs_to user" do
    post = posts(:post_one)
    assert_respond_to post, :user
    assert_equal users(:admin), post.user
  end
end
