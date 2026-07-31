class IssueComment < ActiveRecord::Base

  belongs_to :issue
  belongs_to :user
  has_many :comment_reactions, dependent: :destroy
  
  validates :content, presence: true
  
  scope :chronological, -> { order(created_at: :asc) }
  
  after_create :notify_subscribers
  
  private
  
  def notify_subscribers
    UserSubscription.where(issue_id: issue.id).includes(:user).find_each do |subscription|
      Notification.create!(
        user: subscription.user,
        message: "New comment on issue ##{issue.id}: #{content.truncate(50)}",
        notification_type: :issue_comment
      )
    end
  end

end
