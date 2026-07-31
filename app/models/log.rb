class Log < ActiveRecord::Base
  belongs_to :job_run, optional: true
  has_many :log_comments, dependent: :destroy

  validates :content, presence: true

  scope :recent, -> { order(created_at: :desc).limit(20) }

  def parsed_entries
    LogParser.parse_text(content)
  end
end
