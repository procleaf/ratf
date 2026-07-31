require "test_helper"

class LogTest < ActiveSupport::TestCase
  test "valid with required attributes" do
    log = logs(:run_log)
    assert log.valid?
  end

  test "invalid without content" do
    log = logs(:run_log)
    log.content = nil
    assert_not log.valid?
    assert_includes log.errors[:content], "can't be blank"
  end

  test "belongs_to job_run optional" do
    log = logs(:run_log)
    assert_respond_to log, :job_run
    assert_equal job_runs(:completed_run), log.job_run
  end

  test "scope recent returns ordered by created_at desc" do
    logs = Log.recent
    assert logs.is_a?(ActiveRecord::Relation)
  end

  test "parsed_entries returns array from LogParser" do
    log = logs(:run_log)
    entries = log.parsed_entries
    assert entries.is_a?(Array)
    assert entries.size >= 2
  end
end
