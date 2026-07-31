require "test_helper"

class ProjectTest < ActiveSupport::TestCase
  test "valid with required attributes" do
    project = projects(:active_project)
    assert project.valid?
  end

  test "invalid without name" do
    project = projects(:active_project)
    project.name = nil
    assert_not project.valid?
    assert_includes project.errors[:name], "can't be blank"
  end

  test "invalid with duplicate name" do
    project = Project.new(name: projects(:active_project).name)
    assert_not project.valid?
    assert_includes project.errors[:name], "has already been taken"
  end

  test "has_many test_suites" do
    project = projects(:active_project)
    assert_respond_to project, :test_suites
  end

  test "scope active returns non-archived projects" do
    active = Project.active
    assert_includes active, projects(:active_project)
    assert_not_includes active, projects(:archived_project)
  end

  test "scope archived returns archived projects" do
    archived = Project.archived
    assert_includes archived, projects(:archived_project)
    assert_not_includes archived, projects(:active_project)
  end

  test "archive! sets archived_at" do
    project = projects(:active_project)
    project.archive!
    assert project.archived?
    assert_not_nil project.archived_at
  end

  test "archived? returns false for active project" do
    assert_not projects(:active_project).archived?
  end

  test "archived? returns true for archived project" do
    assert projects(:archived_project).archived?
  end
end
