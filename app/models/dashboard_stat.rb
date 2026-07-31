class DashboardStat < ActiveRecord::Base
  # Not a database table, but a view model

  def self.get_stats
    {
      total_jobs: Job.count,
      running_jobs: Job.where(status: :running).count,
      queued_jobs: Job.where(status: :queued).count,
      success_rate: calculate_success_rate,
      avg_duration: calculate_avg_duration,
      # Chart data
      job_status_distribution: job_status_distribution,
      test_result_distribution: test_result_distribution,
      recent_activity: recent_activity,
      flaky_tests: flaky_tests,
      slowest_tests: slowest_tests,
      trend_data: trend_data
    }
  end

  private

  def self.calculate_success_rate
    completed = JobRun.where(status: :completed).count
    failed = JobRun.where(status: :failed).count
    return 0 if completed + failed == 0
    (completed.to_f / (completed + failed) * 100).round(2)
  end

  def self.calculate_avg_duration
    runs = JobRun.where.not(completed_at: nil).where.not(started_at: nil)
    return nil if runs.empty?
    total = runs.sum { |r| (r.completed_at - r.started_at).to_f }
    (total / runs.size).round(2)
  end

  def self.job_status_distribution
    Job.statuses.keys.map { |status|
      [status.humanize, Job.where(status: status).count]
    }.to_h
  end

  def self.test_result_distribution
    TestResult.statuses.keys.map { |status|
      [status.humanize, TestResult.where(status: status).count]
    }.to_h
  end

  def self.recent_activity
    JobRun.order(created_at: :desc).limit(8).map do |run|
      {
        id: run.id,
        job_name: run.job&.name || "Unknown",
        status: run.status,
        duration: run.duration,
        time: run.created_at
      }
    end
  end

  def self.flaky_tests
    TestCase.joins(:test_results)
      .group("test_cases.id", "test_cases.name")
      .having("COUNT(test_results.id) >= ?", 5)
      .select("test_cases.id, test_cases.name,
        COUNT(test_results.id) as total_runs,
        SUM(CASE WHEN test_results.status = 0 THEN 1 ELSE 0 END) as passes,
        ROUND(CAST(SUM(CASE WHEN test_results.status = 0 THEN 1 ELSE 0 END) AS FLOAT) / COUNT(test_results.id) * 100, 1) as pass_rate")
      .order(Arel.sql("pass_rate ASC"))
      .limit(10)
      .map do |tc|
        {
          id: tc.id,
          name: tc.name,
          total_runs: tc.total_runs,
          pass_rate: tc.pass_rate.to_f
        }
      end
  end

  def self.slowest_tests
    TestResult.where.not(execution_time: nil)
      .order(execution_time: :desc)
      .limit(10)
      .map do |tr|
        {
          id: tr.id,
          name: tr.name,
          execution_time: tr.execution_time,
          test_case_id: tr.test_case_id,
          status: tr.status
        }
      end
  end

  def self.trend_data
    # Last 7 days of test result trends
    7.downto(0).map do |days_ago|
      date = days_ago.days.ago.to_date
      day_results = TestResult.where(created_at: date.all_day)
      total = day_results.count
      passed = day_results.where(status: :passed).count
      {
        date: date.to_s,
        total: total,
        passed: passed,
        pass_rate: total > 0 ? (passed.to_f / total * 100).round(1) : 0
      }
    end
  end
end
