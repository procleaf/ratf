class Issue < ActiveRecord::Base

  belongs_to :test_case, optional: true
  belongs_to :test_result, optional: true
  belongs_to :reported_by, class_name: 'User'
  belongs_to :assigned_to, class_name: 'User', optional: true
  has_many :issue_comments, dependent: :destroy
  has_many :issue_attachments, dependent: :destroy
  
  enum :status, { 
    open: 0, 
    in_progress: 1, 
    resolved: 2, 
    closed: 3, 
    reopened: 4 
  }
  
  enum :severity, { 
    trivial: 0, 
    minor: 1, 
    major: 2, 
    critical: 3, 
    blocker: 4 
  }, prefix: :severity
  
  enum :urgency, {
    low: 0,
    medium: 1,
    high: 2,
    critical: 3
  }, prefix: :urgency
  
  enum :issue_type, { 
    bug: 0, 
    enhancement: 1, 
    feature_request: 2, 
    question: 3, 
    technical_debt: 4 
  }
  
  validates :title, presence: true
  validates :description, presence: true
  
  scope :open_issues, -> { where(status: [:open, :in_progress, :reopened]) }
  scope :by_severity, ->(severity) { where(severity: severity) }
  scope :assigned_to_user, ->(user_id) { where(assigned_to_id: user_id) }
  
  def priority_score
    severity_weight = { trivial: 1, minor: 2, major: 3, critical: 4, blocker: 5 }
    urgency_weight = { low: 1, medium: 2, high: 3, critical: 4 }
    
    (severity_weight[severity.to_sym] || 0) + (urgency_weight[urgency.to_sym] || 0)
  end
  
  def open?
    status == "open"
  end

  def can_close?
    !closed?
  end

  def time_open
    return nil if closed_at.nil?
    (closed_at - created_at).round(2)
  end
  
  def formatted_time_open
    return 'Open' if closed_at.nil?
    seconds = time_open
    hours = (seconds / 3600).floor
    minutes = ((seconds % 3600) / 60).floor
    days = (hours / 24).floor
    hours = hours % 24
    
    "#{days}d #{hours}h #{minutes}m"
  end
  
  def can_close?
    [:resolved, :closed].include?(status.to_sym)
  end
  
  def reassign_to(user)
    update(assigned_to: user, status: :in_progress)
    Notification.create!(
      user: user,
      message: "Issue ##{id} assigned to you: #{title}",
      notification_type: :issue_assignment
    )
  end
  
  def add_comment(user, content)
    issue_comments.create!(user: user, content: content)
  end
  
  def to_json_api
    {
      id: id,
      title: title,
      description: description,
      status: status,
      severity: severity,
      type: issue_type,
      priority_score: priority_score,
      assigned_to: assigned_to&.username,
      reported_by: reported_by.username,
      created_at: created_at.iso8601,
      updated_at: updated_at.iso8601,
      comments_count: issue_comments.count
    }
  end
end
