# frozen_string_literal: true
# UserStat — denormalized user statistics (Discourse pattern)
# Updated via callbacks on associated models for performance.
class UserStat < ActiveRecord::Base
  belongs_to :user

  def success_rate
    total = jobs_completed_count + jobs_failed_count
    return 0 if total.zero?
    (jobs_completed_count.to_f / total * 100).round(2)
  end
end
