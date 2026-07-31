# frozen_string_literal: true
# UserPreference — per-user settings stored in DB (Discourse pattern)
# Falls back to localStorage for theme/locale if not set.
class UserPreference < ActiveRecord::Base
  belongs_to :user

  validates :theme, inclusion: { in: %w[light dark system] }
  validates :locale, inclusion: { in: %w[en zh] }
end
