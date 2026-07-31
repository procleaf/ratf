require "test_helper"

class JobsControllerTest < ActionDispatch::IntegrationTest
  setup do
    post login_url, params: { email: "admin@ratf.test", password: "password" }
  end

  test "should get index" do
    get jobs_url
    assert_response :success
  end

  test "should get show" do
    job = jobs(:pending_job)
    get job_url(job)
    assert_response :success
  end

  test "should get new" do
    get new_job_url
    assert_response :success
  end

  test "should create job" do
    assert_difference("Job.count") do
      post jobs_url, params: { job: { name: "New Job", description: "A test job", created_by_id: users(:admin).id, definition: { steps: ["step1"] } } }
    end
    assert_redirected_to job_url(Job.last)
    assert_equal "Job was successfully created.", flash[:notice]
  end

  test "should not create job with invalid params" do
    post jobs_url, params: { job: { name: "" } }
    assert_response :unprocessable_entity
  end

  test "should get edit" do
    job = jobs(:pending_job)
    get edit_job_url(job)
    assert_response :success
  end

  test "should update job" do
    job = jobs(:pending_job)
    patch job_url(job), params: { job: { name: "Updated Job" } }
    assert_redirected_to job_url(job)
    assert_equal "Job was successfully updated.", flash[:notice]
  end

  test "should not update job with invalid params" do
    job = jobs(:pending_job)
    patch job_url(job), params: { job: { name: "" } }
    assert_response :unprocessable_entity
  end

  test "should destroy job" do
    job = Job.create!(name: "temp-job-delete", created_by: users(:admin), definition: { steps: ["cleanup"] })
    assert_difference("Job.count", -1) do
      delete job_url(job)
    end
    assert_redirected_to jobs_url
    assert_equal "Job was successfully deleted.", flash[:notice]
  end
end
