require "test_helper"

class TestCaseTagTest < ActiveSupport::TestCase
  test "valid with required attributes" do
    tct = test_case_tags(:login_smoke)
    assert tct.valid?
  end

  test "invalid with duplicate test_case and tag" do
    existing = test_case_tags(:login_smoke)
    dup = TestCaseTag.new(test_case: existing.test_case, tag: existing.tag)
    assert_not dup.valid?
    assert_includes dup.errors[:test_case_id], "has already been taken"
  end

  test "belongs_to test_case" do
    tct = test_case_tags(:login_smoke)
    assert_respond_to tct, :test_case
    assert_equal test_cases(:login_test), tct.test_case
  end

  test "belongs_to tag" do
    tct = test_case_tags(:login_smoke)
    assert_respond_to tct, :tag
    assert_equal tags(:smoke_tag), tct.tag
  end
end
