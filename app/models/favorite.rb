# frozen_string_literal: true
class Favorite < ActiveRecord::Base
  belongs_to :user
  belongs_to :test_case

  validates :user_id, uniqueness: { scope: :test_case_id }

  scope :for_user, ->(user) { where(user: user) }
end
