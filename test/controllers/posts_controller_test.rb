require "test_helper"

class PostsControllerTest < ActionDispatch::IntegrationTest
  setup do
    post login_url, params: { email: "admin@ratf.test", password: "password" }
  end

  test "should get index" do
    get posts_url
    assert_response :success
  end

  test "should get show" do
    post_record = posts(:post_one)
    get post_url(post_record)
    assert_response :success
  end

  test "should get new" do
    get new_post_url
    assert_response :success
  end

  test "should create post" do
    assert_difference("Post.count") do
      post posts_url, params: { post: { title: "New Post", content: "Post content" } }
    end
    assert_redirected_to post_url(Post.last)
    assert_equal "Post was successfully created.", flash[:notice]
  end

  test "should not create post with invalid params" do
    post posts_url, params: { post: { title: "" } }
    assert_response :unprocessable_entity
  end

  test "should get edit" do
    post_record = posts(:post_one)
    get edit_post_url(post_record)
    assert_response :success
  end

  test "should update post" do
    post_record = posts(:post_one)
    patch post_url(post_record), params: { post: { title: "Updated Post" } }
    assert_redirected_to post_url(post_record)
    assert_equal "Post was successfully updated.", flash[:notice]
  end

  test "should not update post with invalid params" do
    post_record = posts(:post_one)
    patch post_url(post_record), params: { post: { title: "" } }
    assert_response :unprocessable_entity
  end

  test "should destroy post" do
    post_record = posts(:post_one)
    assert_difference("Post.count", -1) do
      delete post_url(post_record)
    end
    assert_redirected_to posts_url
    assert_equal "Post was successfully deleted.", flash[:notice]
  end
end
