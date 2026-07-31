class TestSuiteRun < ActiveRecord::Base

  belongs_to :test_suite
  belongs_to :job_run
  
  enum :status, { pending: 0, running: 1, completed: 2, failed: 3 }
  
  validates :test_suite_id, uniqueness: { scope: :job_run_id }
  
  def duration
    return nil unless ended_at && started_at
    (ended_at - started_at).round(2)
  end
  
  def success_rate
    return 0 if total_tests == 0
    (passed_tests.to_f / total_tests * 100).round(2)
  end
  
  def update_stats(test_results)
    self.total_tests = test_results.count
    self.passed_tests = test_results.passed.count
    self.failed_tests = test_results.failed.count
    self.skipped_tests = test_results.skipped.count
    self.errored_tests = test_results.error.count
    self.total_duration = test_results.sum(:execution_time)
    save!
  end

end
