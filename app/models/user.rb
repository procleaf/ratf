# frozen_string_literal: true
# User model — inspired by Discourse's user.rb
# Uses denormalized UserStat for performance, UserPreference for settings,
# and rich scopes/callbacks for maintainability.
class User < ActiveRecord::Base
  has_secure_password

  # ── Associations ────────────────────────────────────────────
  has_many :jobs, foreign_key: :created_by_id, dependent: :restrict_with_error
  has_many :job_runs, through: :jobs
  has_many :notifications, dependent: :destroy
  has_many :test_cases, foreign_key: :created_by_id
  has_many :reported_issues, class_name: "Issue", foreign_key: :reported_by_id
  has_many :api_tokens, dependent: :destroy
  has_many :cloud_providers, dependent: :restrict_with_error
  has_many :favorites, dependent: :destroy
  has_many :favorite_test_cases, through: :favorites, source: :test_case
  has_many :issue_comments, foreign_key: :user_id
  has_many :posts, foreign_key: :user_id

  has_one :user_stat, dependent: :destroy, autosave: true
  has_one :user_preference, dependent: :destroy, autosave: true

  # ── Transient Attributes (not persisted) ─────────────────────
  attr_accessor :skip_email_validation
  attr_accessor :send_welcome_message
  attr_accessor :impersonated_by  # admin impersonation tracking

  # ── Validations ─────────────────────────────────────────────
  validates :email, presence: true, uniqueness: true,
            format: { with: URI::MailTo::EMAIL_REGEXP },
            unless: :skip_email_validation
  validates :username, presence: true, uniqueness: true,
            length: { minimum: 2, maximum: 50 },
            format: { with: /\A[a-zA-Z0-9_\-.]+\z/, message: "only allows letters, numbers, underscores, hyphens, and dots" }

  # ── Enums ───────────────────────────────────────────────────
  enum :role, { user: 0, admin: 1, manager: 2 }

  # ── Scopes ──────────────────────────────────────────────────
  scope :admins, -> { where(role: :admin) }
  scope :staff, -> { where(role: [:admin, :manager]) }
  scope :regular, -> { where(role: :user) }
  scope :active, -> { where("last_active_at > ?", 30.minutes.ago) }
  scope :recent, -> { order(created_at: :desc) }
  scope :by_username, ->(name) { where("username LIKE ?", "%#{name}%") }
  scope :with_stats, -> { includes(:user_stat) }

  # ── Callbacks ───────────────────────────────────────────────
  before_validation :normalize_email, if: :email_changed?
  after_create :create_user_stat!
  after_create :create_user_preference!
  after_create :send_welcome, if: :send_welcome_message
  after_save :update_stat_counts, if: :saved_change_to_role?

  # ── Delegation (UserStat) ───────────────────────────────────
  delegate :jobs_created_count, :jobs_completed_count, :jobs_failed_count,
           :test_cases_count, :issues_reported_count, :issues_resolved_count,
           :api_tokens_count, :comments_count, :posts_count,
           :days_visited, :first_job_created_at, :last_job_created_at,
           :success_rate,
           to: :user_stat, allow_nil: true

  # ── Display ─────────────────────────────────────────────────
  def name
    username
  end

  def display_name
    username
  end

  def avatar_letter
    username[0].upcase
  end

  # ── Status Checks ───────────────────────────────────────────
  def active?
    last_active_at.present? && last_active_at > 30.minutes.ago
  end

  def staff?
    admin? || manager?
  end

  def super_admin?
    admin?
  end

  # ── Activity Tracking ───────────────────────────────────────
  def record_visit!
    touch(:last_active_at)
    user_stat.increment!(:days_visited) if last_active_at_previously_changed?
  end

  def total_jobs_run
    user_stat&.jobs_completed_count || jobs.where(status: :completed).count
  end

  def job_success_rate
    user_stat&.success_rate || calculate_success_rate
  end

  # ── Preferences ─────────────────────────────────────────────
  def theme_preference
    user_preference&.theme || "system"
  end

  def locale_preference
    user_preference&.locale || "en"
  end

  def wants_notification?(type)
    return true unless user_preference
    case type
    when :job_completed then user_preference.job_completed_notify
    when :job_failed    then user_preference.job_failed_notify
    when :issue         then user_preference.issue_notify
    when :comment       then user_preference.comment_notify
    else true
    end
  end

  # ── Token Management ────────────────────────────────────────
  def ensure_api_token
    return unless api_tokens.empty?
    api_tokens.create!(name: "Default Token")
  end

  # ── Private ─────────────────────────────────────────────────
  private

  def normalize_email
    self.email = email.to_s.strip.downcase
  end

  def send_welcome
    Notification.create!(
      user: self,
      notification_type: :system,
      message: "Welcome to RATF, #{username}!"
    )
  end

  def calculate_success_rate
    completed = jobs.where(status: :completed).count
    failed = jobs.where(status: :failed).count
    return 0 if completed + failed == 0
    (completed.to_f / (completed + failed) * 100).round(2)
  end

  def update_stat_counts
    # Recalculate denormalized stats when role changes
    # (handled by callbacks on associated models)
  end
end
