require "test_helper"

class JobArtifactTest < ActiveSupport::TestCase
  test "valid with required attributes" do
    artifact = job_artifacts(:log_artifact)
    assert artifact.valid?
  end

  test "invalid without name" do
    artifact = job_artifacts(:log_artifact)
    artifact.name = nil
    assert_not artifact.valid?
    assert_includes artifact.errors[:name], "can't be blank"
  end

  test "enum artifact_type has correct values" do
    expected = { "log" => 0, "report" => 1, "screenshot" => 2, "video" => 3, "data" => 4 }
    assert_equal expected, JobArtifact.artifact_types
  end

  test "belongs_to job" do
    artifact = job_artifacts(:log_artifact)
    assert_respond_to artifact, :job
    assert_equal jobs(:completed_job), artifact.job
  end

  test "human_readable_size returns 0 B when no file attached" do
    artifact = job_artifacts(:log_artifact)
    assert_equal "0 B", artifact.human_readable_size
  end
end
