require "test_helper"

class JobArtifactsControllerTest < ActionDispatch::IntegrationTest
  setup do
    post login_url, params: { email: "admin@ratf.test", password: "password" }
  end

  test "should get index" do
    get job_artifacts_url
    assert_response :success
  end

  test "should get show" do
    job_artifact = job_artifacts(:log_artifact)
    get job_artifact_url(job_artifact)
    assert_response :success
  end

  test "should get new" do
    get new_job_artifact_url
    assert_response :success
  end

  test "should create job_artifact" do
    assert_difference("JobArtifact.count") do
      post job_artifacts_url, params: { job_artifact: { job_id: jobs(:pending_job).id, name: "artifact.log", artifact_type: "log" } }
    end
    assert_redirected_to job_artifact_url(JobArtifact.last)
    assert_equal "Job artifact was successfully created.", flash[:notice]
  end

  test "should not create job_artifact with invalid params" do
    post job_artifacts_url, params: { job_artifact: { name: "" } }
    assert_response :unprocessable_entity
  end

  test "should get edit" do
    job_artifact = job_artifacts(:log_artifact)
    get edit_job_artifact_url(job_artifact)
    assert_response :success
  end

  test "should update job_artifact" do
    job_artifact = job_artifacts(:log_artifact)
    patch job_artifact_url(job_artifact), params: { job_artifact: { name: "updated.log" } }
    assert_redirected_to job_artifact_url(job_artifact)
    assert_equal "Job artifact was successfully updated.", flash[:notice]
  end

  test "should not update job_artifact with invalid params" do
    job_artifact = job_artifacts(:log_artifact)
    patch job_artifact_url(job_artifact), params: { job_artifact: { name: "" } }
    assert_response :unprocessable_entity
  end

  test "should destroy job_artifact" do
    job_artifact = job_artifacts(:log_artifact)
    assert_difference("JobArtifact.count", -1) do
      delete job_artifact_url(job_artifact)
    end
    assert_redirected_to job_artifacts_url
    assert_equal "Job artifact was successfully deleted.", flash[:notice]
  end
end
