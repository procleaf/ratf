require "test_helper"

class ScheduleTest < ActiveSupport::TestCase
  test "valid with required attributes" do
    schedule = schedules(:daily_smoke)
    assert schedule.valid?
  end

  test "invalid without name" do
    schedule = schedules(:daily_smoke)
    schedule.name = nil
    assert_not schedule.valid?
    assert_includes schedule.errors[:name], "can't be blank"
  end

  test "invalid without cron_expression" do
    schedule = schedules(:daily_smoke)
    schedule.cron_expression = nil
    assert_not schedule.valid?
    assert_includes schedule.errors[:cron_expression], "can't be blank"
  end

  test "belongs_to job" do
    schedule = schedules(:daily_smoke)
    assert_respond_to schedule, :job
    assert_equal jobs(:pending_job), schedule.job
  end

  test "enabled? returns true when enabled" do
    schedule = schedules(:daily_smoke)
    assert schedule.enabled?
  end

  test "enabled? returns false when disabled" do
    schedule = schedules(:weekly_regression)
    assert_not schedule.enabled?
  end

  test "should_run? returns false when disabled" do
    schedule = schedules(:weekly_regression)
    assert_not schedule.should_run?
  end

  test "should_run? returns true when enabled and next_run_at is past" do
    schedule = schedules(:daily_smoke)
    schedule.next_run_at = 1.hour.ago
    assert schedule.should_run?
  end

  test "should_run? returns false when next_run_at is nil" do
    schedule = schedules(:daily_smoke)
    schedule.next_run_at = nil
    assert_not schedule.should_run?
  end

  test "should_run? returns false when next_run_at is in future" do
    schedule = schedules(:daily_smoke)
    schedule.next_run_at = 1.hour.from_now
    assert_not schedule.should_run?
  end

  test "scope due returns enabled schedules past due" do
    schedule = schedules(:daily_smoke)
    schedule.update_column(:next_run_at, 1.hour.ago)
    due = Schedule.due
    assert_includes due, schedule
    assert_not_includes due, schedules(:weekly_regression)
  end

  test "scope due excludes disabled schedules" do
    schedule = schedules(:weekly_regression)
    schedule.update_column(:next_run_at, 1.hour.ago)
    due = Schedule.due
    assert_not_includes due, schedule
  end
end
