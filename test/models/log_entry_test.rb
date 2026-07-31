require "test_helper"

class LogEntryTest < ActiveSupport::TestCase
  test "valid with required attributes" do
    entry = log_entries(:info_entry)
    assert entry.valid?
  end

  test "invalid without message" do
    entry = log_entries(:info_entry)
    entry.message = nil
    assert_not entry.valid?
    assert_includes entry.errors[:message], "can't be blank"
  end

  test "invalid without log_level" do
    entry = log_entries(:info_entry)
    entry.log_level = nil
    assert_not entry.valid?
    assert_includes entry.errors[:log_level], "can't be blank"
  end

  test "enum log_level has correct values" do
    expected = { "debug" => 0, "info" => 1, "warn" => 2, "error" => 3, "fatal" => 4 }
    assert_equal expected, LogEntry.log_levels
  end

  test "belongs_to job_run optional" do
    entry = log_entries(:info_entry)
    assert_respond_to entry, :job_run
    assert_equal job_runs(:completed_run), entry.job_run
  end

  test "belongs_to test_case optional" do
    entry = log_entries(:error_entry)
    assert_respond_to entry, :test_case
    assert_equal test_cases(:dashboard_test), entry.test_case
  end

  test "scope recent returns ordered by timestamp desc" do
    entries = LogEntry.recent
    assert entries.is_a?(ActiveRecord::Relation)
  end

  test "scope by_level filters correctly" do
    infos = LogEntry.by_level(:info)
    assert_includes infos, log_entries(:info_entry)
    assert_not_includes infos, log_entries(:error_entry)
  end

  test "scope by_time_range filters correctly" do
    start_time = 2.hours.ago
    end_time = Time.now
    entries = LogEntry.by_time_range(start_time, end_time)
    assert entries.is_a?(ActiveRecord::Relation)
  end

  test "before_create sets timestamp" do
    entry = LogEntry.create!(message: "test", log_level: :info)
    assert_not_nil entry.timestamp
  end

  test "formatted_message includes timestamp and level" do
    msg = log_entries(:info_entry).formatted_message
    assert_includes msg, "[INFO]"
    assert_includes msg, "Test suite execution started"
  end

  test "color_code returns ANSI code" do
    assert_equal '\e[32m', log_entries(:info_entry).color_code
    assert_equal '\e[33m', log_entries(:warn_entry).color_code
    assert_equal '\e[31m', log_entries(:error_entry).color_code
  end

  test "to_json returns hash" do
    json = log_entries(:info_entry).to_json
    assert json.key?(:level)
    assert json.key?(:message)
  end
end
