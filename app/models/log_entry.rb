class LogEntry < ActiveRecord::Base

  belongs_to :job_run, optional: true
  belongs_to :test_case, optional: true
  
  enum :log_level, { 
    debug: 0, 
    info: 1, 
    warn: 2, 
    error: 3, 
    fatal: 4 
  }
  
  validates :message, presence: true
  validates :log_level, presence: true
  
  scope :recent, -> { order(timestamp: :desc).limit(100) }
  scope :by_level, ->(level) { where(log_level: level) }
  scope :by_time_range, ->(start, end_time) { where(timestamp: start..end_time) }
  
  before_create :set_timestamp
  
  def formatted_message
    "#{timestamp.strftime('%Y-%m-%d %H:%M:%S')} [#{log_level.to_s.upcase}] #{source || 'RATF'} - #{message}"
  end
  
  def color_code
    {
      debug: '\e[36m',   # Cyan
      info: '\e[32m',    # Green
      warn: '\e[33m',    # Yellow
      error: '\e[31m',   # Red
      fatal: '\e[35m'    # Magenta
    }[log_level.to_sym] || '\e[37m' # White
  end
  
  def to_json
    {
      timestamp: timestamp.iso8601(3),
      level: log_level,
      source: source,
      message: message,
      metadata: metadata,
      job_run_id: job_run_id,
      test_case_id: test_case_id
    }
  end
  
  private
  
  def set_timestamp
    self.timestamp ||= Time.now
  end
end

