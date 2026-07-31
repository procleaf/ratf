require "test_helper"

class TestCasesControllerTest < ActionDispatch::IntegrationTest
  setup do
    post login_url, params: { email: "admin@ratf.test", password: "password" }
  end

  test "should get index" do
    get test_cases_url
    assert_response :success
  end

  test "should get show" do
    test_case = test_cases(:login_test)
    get test_case_url(test_case)
    assert_response :success
  end

  test "should get new" do
    get new_test_case_url
    assert_response :success
  end

  test "should create test_case" do
    assert_difference("TestCase.count") do
      post test_cases_url, params: { test_case: { test_suite_id: test_suites(:smoke_suite).id, name: "New Test Case", created_by_id: users(:admin).id, description: "A test", status: "active", priority: "medium", test_type: "functional" } }
    end
    assert_redirected_to test_case_url(TestCase.last)
    assert_equal "Test case was successfully created.", flash[:notice]
  end

  test "should not create test_case with invalid params" do
    post test_cases_url, params: { test_case: { name: "" } }
    assert_response :unprocessable_entity
  end

  test "should get edit" do
    test_case = test_cases(:login_test)
    get edit_test_case_url(test_case)
    assert_response :success
  end

  test "should update test_case" do
    test_case = test_cases(:login_test)
    patch test_case_url(test_case), params: { test_case: { name: "Updated Test Case" } }
    assert_redirected_to test_case_url(test_case)
    assert_equal "Test case was successfully updated.", flash[:notice]
  end

  test "should not update test_case with invalid params" do
    test_case = test_cases(:login_test)
    patch test_case_url(test_case), params: { test_case: { name: "" } }
    assert_response :unprocessable_entity
  end

  test "should destroy test_case" do
    test_case = TestCase.create!(name: "temp-case-delete", test_suite: test_suites(:smoke_suite), created_by: users(:admin), test_type: :functional)
    assert_difference("TestCase.count", -1) do
      delete test_case_url(test_case)
    end
    assert_redirected_to test_cases_url
    assert_equal "Test case was successfully deleted.", flash[:notice]
  end
end
