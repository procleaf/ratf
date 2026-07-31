require "test_helper"

class TestSuitesControllerTest < ActionDispatch::IntegrationTest
  setup do
    post login_url, params: { email: "admin@ratf.test", password: "password" }
  end

  test "should get index" do
    get test_suites_url
    assert_response :success
  end

  test "should get show" do
    test_suite = test_suites(:smoke_suite)
    get test_suite_url(test_suite)
    assert_response :success
  end

  test "should get new" do
    get new_test_suite_url
    assert_response :success
  end

  test "should create test_suite" do
    assert_difference("TestSuite.count") do
      post test_suites_url, params: { test_suite: { project_id: projects(:active_project).id, name: "New Suite", version: "1.0.0", status: "active" } }
    end
    assert_redirected_to test_suite_url(TestSuite.last)
    assert_equal "Test suite was successfully created.", flash[:notice]
  end

  test "should not create test_suite with invalid params" do
    post test_suites_url, params: { test_suite: { name: "" } }
    assert_response :unprocessable_entity
  end

  test "should get edit" do
    test_suite = test_suites(:smoke_suite)
    get edit_test_suite_url(test_suite)
    assert_response :success
  end

  test "should update test_suite" do
    test_suite = test_suites(:smoke_suite)
    patch test_suite_url(test_suite), params: { test_suite: { name: "Updated Suite" } }
    assert_redirected_to test_suite_url(test_suite)
    assert_equal "Test suite was successfully updated.", flash[:notice]
  end

  test "should not update test_suite with invalid params" do
    test_suite = test_suites(:smoke_suite)
    patch test_suite_url(test_suite), params: { test_suite: { name: "" } }
    assert_response :unprocessable_entity
  end

  test "should destroy test_suite" do
    test_suite = TestSuite.create!(name: "temp-suite-delete", version: "1.0.0")
    assert_difference("TestSuite.count", -1) do
      delete test_suite_url(test_suite)
    end
    assert_redirected_to test_suites_url
    assert_equal "Test suite was successfully deleted.", flash[:notice]
  end
end
