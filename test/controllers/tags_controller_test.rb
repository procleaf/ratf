require "test_helper"

class TagsControllerTest < ActionDispatch::IntegrationTest
  setup do
    post login_url, params: { email: "admin@ratf.test", password: "password" }
  end

  test "should get index" do
    get tags_url
    assert_response :success
  end

  test "should get show" do
    tag = tags(:smoke_tag)
    get tag_url(tag)
    assert_response :success
  end

  test "should get new" do
    get new_tag_url
    assert_response :success
  end

  test "should create tag" do
    assert_difference("Tag.count") do
      post tags_url, params: { tag: { name: "new-tag" } }
    end
    assert_redirected_to tag_url(Tag.last)
    assert_equal "Tag was successfully created.", flash[:notice]
  end

  test "should not create tag with invalid params" do
    post tags_url, params: { tag: { name: "" } }
    assert_response :unprocessable_entity
  end

  test "should get edit" do
    tag = tags(:smoke_tag)
    get edit_tag_url(tag)
    assert_response :success
  end

  test "should update tag" do
    tag = tags(:smoke_tag)
    patch tag_url(tag), params: { tag: { name: "updated-tag" } }
    assert_redirected_to tag_url(tag)
    assert_equal "Tag was successfully updated.", flash[:notice]
  end

  test "should not update tag with invalid params" do
    tag = tags(:smoke_tag)
    patch tag_url(tag), params: { tag: { name: "" } }
    assert_response :unprocessable_entity
  end

  test "should destroy tag" do
    tag = tags(:smoke_tag)
    assert_difference("Tag.count", -1) do
      delete tag_url(tag)
    end
    assert_redirected_to tags_url
    assert_equal "Tag was successfully deleted.", flash[:notice]
  end
end
