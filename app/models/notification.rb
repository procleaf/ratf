class Notification < ActiveRecord::Base
  belongs_to :user

  enum :notification_type, {
    issue_assignment: 0,
    issue_comment: 1,
    job_completed: 2,
    job_failed: 3,
    test_failure: 4,
    system: 5
  }

  validates :message, presence: true
  validates :notification_type, presence: true

  scope :unread, -> { where(read_at: nil) }
  scope :recent, -> { order(created_at: :desc).limit(50) }

  def mark_as_read!
    update!(read_at: Time.now)
  end

  def read?
    read_at.present?
  end
end
