require "test_helper"

class TagTest < ActiveSupport::TestCase
  test "valid with required attributes" do
    tag = tags(:smoke_tag)
    assert tag.valid?
  end

  test "invalid without name" do
    tag = tags(:smoke_tag)
    tag.name = nil
    assert_not tag.valid?
    assert_includes tag.errors[:name], "can't be blank"
  end

  test "invalid with duplicate name" do
    tag = Tag.new(name: tags(:smoke_tag).name)
    assert_not tag.valid?
    assert_includes tag.errors[:name], "has already been taken"
  end

  test "has_many test_case_tags" do
    tag = tags(:smoke_tag)
    assert_respond_to tag, :test_case_tags
  end

  test "has_many test_cases through test_case_tags" do
    tag = tags(:smoke_tag)
    assert_respond_to tag, :test_cases
    assert_equal 2, tag.test_cases.count
  end

  test "scope by_name finds partial match" do
    results = Tag.by_name("smo")
    assert_includes results, tags(:smoke_tag)
  end
end
