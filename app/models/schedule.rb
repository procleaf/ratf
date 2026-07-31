class Schedule < ApplicationRecord
  belongs_to :job

  validates :name, presence: true
  validates :cron_expression, presence: true

  scope :due, -> { where(enabled: true).where("next_run_at <= ?", Time.current) }

  def enabled?
    enabled
  end

  def should_run?
    enabled? && next_run_at.present? && next_run_at <= Time.current
  end

  def record_run!
    now = Time.current
    update!(
      last_run_at: now,
      run_count: run_count + 1,
      next_run_at: calculate_next_run(now)
    )
  end

  private

  def calculate_next_run(after: Time.current)
    cron = Fugit::Cron.parse(cron_expression)
    return nil unless cron

    cron.next_time(after)&.to_local_time
  end
end
