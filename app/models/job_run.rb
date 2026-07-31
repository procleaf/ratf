class JobRun < ActiveRecord::Base

  belongs_to :job
  has_many :test_results
  
  enum :status, { pending: 0, running: 1, completed: 2, failed: 3, cancelled: 4 }
  
  validates :started_at, presence: true
  
  scope :running, -> { where(status: :running) }
  scope :completed_today, -> { where(completed_at: Time.now.beginning_of_day..Time.now.end_of_day) }
  
  before_create :set_start_time
  
  def duration
    return nil unless completed_at && started_at
    (completed_at - started_at).round(2)
  end
  
  def log_stream
    @log_stream ||= begin
      log_file = Rails.root.join('logs', 'job_runs', "#{id}.log")
      log_file.exist? ? File.read(log_file) : ''
    end
  end
  
  def append_log(message)
    log_file = Rails.root.join('logs', 'job_runs', "#{id}.log")
    FileUtils.mkdir_p(log_file.dirname)
    File.open(log_file, 'a') { |f| f.puts "[#{Time.now.iso8601}] #{message}" }
  end
  
  private
  
  def set_start_time
    self.started_at ||= Time.now
  end

end
