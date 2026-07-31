class TestResult < ActiveRecord::Base

  belongs_to :job_run, optional: true
  belongs_to :test_case, optional: true
  belongs_to :test_suite, optional: true
  has_one :issue, dependent: :nullify
  
  enum :status, { 
    passed: 0, 
    failed: 1, 
    error: 2, 
    skipped: 3, 
    pending: 4 
  }
  
  store_accessor :metadata, :browser, :environment, :os, :version, :tags, :custom_data
  
  validates :name, presence: true
  validates :execution_time, presence: true, if: -> { passed? || failed? || error? }
  
  scope :recent_failures, -> { where(status: :failed).order(created_at: :desc).limit(50) }
  scope :by_suite, ->(suite_id) { where(test_suite_id: suite_id) }
  scope :by_status, ->(status) { where(status: status) }
  scope :executed_many_times, -> { group(:test_case_id).having('COUNT(*) > ?', 5) }
  
  def execution_time_ms
    (execution_time * 1000).round if execution_time
  end
  
  def success?
    status == 'passed'
  end
  
  def failure?
    status == 'failed' || status == 'error'
  end
  
  def failure_message
    return nil if success?
    message || metadata['error_message'] || 'Unknown failure'
  end
  
  def duration
    return nil unless started_at && ended_at
    (ended_at - started_at).round(4)
  end
  
  def formatted_status
    {
      passed: '✅ PASSED',
      failed: '❌ FAILED',
      error: '💥 ERROR',
      skipped: '⏭️ SKIPPED',
      pending: '⏳ PENDING'
    }[status.to_sym] || status.to_s
  end
  
  def create_issue(title, description, reported_by)
    issue = Issue.create!(
      title: title,
      description: description,
      test_case: test_case,
      test_result: self,
      reported_by: reported_by,
      severity: test_case&.priority == 'critical' ? 'critical' : 'major',
      issue_type: :bug
    )
    issue
  end
  
  def to_xunit
    # Generate xUnit compatible XML for CI/CD
    {
      testcase: {
        name: name,
        classname: test_suite&.name || 'Unknown',
        time: execution_time,
        failure: failure? ? { message: failure_message } : nil
      }
    }
  end
  
  # Statistics methods
  class << self
    def success_rate
      passed_count = where(status: :passed).count
      total = count
      return 0 if total.zero?
      (passed_count.to_f / total * 100).round(2)
    end
    
    def average_time
      average(:execution_time)&.round(4)
    end
    
    def stats_overview
      {
        total: count,
        passed: where(status: :passed).count,
        failed: where(status: :failed).count,
        errored: where(status: :error).count,
        skipped: where(status: :skipped).count,
        success_rate: success_rate,
        avg_time: average_time
      }
    end

    def to_csv
      require "csv"
      attributes = %w[id name status execution_time message test_case_id test_suite_id created_at]
      CSV.generate(headers: true) do |csv|
        csv << attributes
        all.find_each do |result|
          csv << attributes.map { |attr| result.send(attr) }
        end
      end
    end
  end
end
