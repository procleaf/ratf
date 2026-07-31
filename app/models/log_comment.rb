class LogComment < ActiveRecord::Base
  belongs_to :log
  belongs_to :user

  validates :content, presence: true

  scope :recent, -> { order(created_at: :desc) }
  scope :by_user, ->(user) { where(user: user) }
end
