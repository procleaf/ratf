class Job < ActiveRecord::Base

  belongs_to :created_by, class_name: 'User'
  has_many :job_runs
  has_many :test_suites, through: :job_runs
  has_many :job_artifacts
  
  # JSON field for job definition
  store_accessor :definition, :steps, :resources, :environment
  
  enum :status, { pending: 0, queued: 1, running: 2, completed: 3, failed: 4, cancelled: 5 }
  enum :priority, { low: 0, normal: 1, high: 2, critical: 3 }
  
  validates :name, presence: true
  validates :definition, presence: true
  
  scope :recent, -> { order(created_at: :desc).limit(10) }
  scope :by_status, ->(status) { where(status: status) }
  scope :by_user, ->(user_id) { where(created_by_id: user_id) }
  
  # Calculate statistics
  def total_runtime
    job_runs.where.not(completed_at: nil).sum { |jr| jr.duration.to_f }
  end
  
  def average_runtime
    runs = job_runs.where.not(completed_at: nil)
    return nil if runs.empty?
    (runs.sum { |jr| jr.duration.to_f } / runs.size).round(2)
  end
  
  def success_rate
    return 0 if job_runs.empty?
    (job_runs.where(status: :completed).count.to_f / job_runs.count * 100).round(2)
  end
  
  def latest_run
    job_runs.order(created_at: :desc).first
  end
  
  def progress_percentage
    return 0 if pending? || queued?
    return 100 if completed? || failed?
    return 0 if job_runs.empty?
    (job_runs.where.not(completed_at: nil).count.to_f / job_runs.count * 100).round(2)
  end

end
