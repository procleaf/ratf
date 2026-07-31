# frozen_string_literal: true
class AuditLog < ActiveRecord::Base
  belongs_to :user, optional: true

  validates :action, presence: true

  scope :recent, -> { order(created_at: :desc).limit(100) }
  scope :by_action, ->(action) { where(action: action) }
  scope :by_user, ->(user_id) { where(user_id: user_id) }

  def self.track!(user:, action:, auditable: nil, changes_made: nil)
    create!(
      user: user,
      action: action,
      auditable_type: auditable&.class&.name,
      auditable_id: auditable&.id,
      changes_made: changes_made || {}
    )
  end
end
