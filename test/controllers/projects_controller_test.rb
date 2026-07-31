require "test_helper"

class ProjectsControllerTest < ActionDispatch::IntegrationTest
  setup do
    post login_url, params: { email: "admin@ratf.test", password: "password" }
  end

  test "should get index" do
    get projects_url
    assert_response :success
  end

  test "should get show" do
    project = projects(:active_project)
    get project_url(project)
    assert_response :success
  end

  test "should get new" do
    get new_project_url
    assert_response :success
  end

  test "should create project" do
    assert_difference("Project.count") do
      post projects_url, params: { project: { name: "New Project", description: "A test project" } }
    end
    assert_redirected_to project_url(Project.last)
    assert_equal "Project was successfully created.", flash[:notice]
  end

  test "should not create project with invalid params" do
    post projects_url, params: { project: { name: "" } }
    assert_response :unprocessable_entity
  end

  test "should get edit" do
    project = projects(:active_project)
    get edit_project_url(project)
    assert_response :success
  end

  test "should update project" do
    project = projects(:active_project)
    patch project_url(project), params: { project: { name: "Updated Project" } }
    assert_redirected_to project_url(project)
    assert_equal "Project was successfully updated.", flash[:notice]
  end

  test "should not update project with invalid params" do
    project = projects(:active_project)
    patch project_url(project), params: { project: { name: "" } }
    assert_response :unprocessable_entity
  end

  test "should destroy project" do
    project = projects(:active_project)
    assert_difference("Project.count", -1) do
      delete project_url(project)
    end
    assert_redirected_to projects_url
    assert_equal "Project was successfully deleted.", flash[:notice]
  end
end
