class UserSubscription < ActiveRecord::Base
  belongs_to :user
  belongs_to :issue

  validates :user_id, uniqueness: { scope: :issue_id }
end
