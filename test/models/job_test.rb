require "test_helper"

class JobTest < ActiveSupport::TestCase
  test "valid with required attributes" do
    job = jobs(:pending_job)
    assert job.valid?
  end

  test "invalid without name" do
    job = jobs(:pending_job)
    job.name = nil
    assert_not job.valid?
    assert_includes job.errors[:name], "can't be blank"
  end

  test "invalid without definition" do
    job = jobs(:pending_job)
    job.definition = nil
    assert_not job.valid?
    assert_includes job.errors[:definition], "can't be blank"
  end

  test "enum status has correct values" do
    expected = { "pending" => 0, "queued" => 1, "running" => 2, "completed" => 3, "failed" => 4, "cancelled" => 5 }
    assert_equal expected, Job.statuses
    assert jobs(:pending_job).pending?
    assert jobs(:running_job).running?
    assert jobs(:completed_job).completed?
    assert jobs(:failed_job).failed?
  end

  test "enum priority has correct values" do
    expected = { "low" => 0, "normal" => 1, "high" => 2, "critical" => 3 }
    assert_equal expected, Job.priorities
  end

  test "belongs_to created_by" do
    job = jobs(:pending_job)
    assert_respond_to job, :created_by
    assert_equal users(:admin), job.created_by
  end

  test "has_many job_runs" do
    job = jobs(:pending_job)
    assert_respond_to job, :job_runs
  end

  test "has_many job_artifacts" do
    job = jobs(:pending_job)
    assert_respond_to job, :job_artifacts
  end

  test "scope recent returns ordered by created_at desc" do
    recent = Job.recent
    assert recent.is_a?(ActiveRecord::Relation)
  end

  test "scope by_status filters correctly" do
    pending_jobs = Job.by_status(:pending)
    assert_includes pending_jobs, jobs(:pending_job)
    assert_not_includes pending_jobs, jobs(:completed_job)
  end

  test "scope by_user filters correctly" do
    admin_jobs = Job.by_user(users(:admin).id)
    assert_includes admin_jobs, jobs(:pending_job)
  end

  test "progress_percentage returns 0 for pending" do
    assert_equal 0, jobs(:pending_job).progress_percentage
  end

  test "progress_percentage returns 100 for completed" do
    assert_equal 100, jobs(:completed_job).progress_percentage
  end

  test "latest_run returns most recent job_run" do
    job = jobs(:completed_job)
    run = job.latest_run
    assert_equal job_runs(:completed_run), run
  end
end
