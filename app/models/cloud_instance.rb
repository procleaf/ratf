# frozen_string_literal: true
class CloudInstance < ActiveRecord::Base
  belongs_to :cloud_provider

  INSTANCE_STATUSES = %w[provisioning running stopping stopped terminated error].freeze

  validates :name, presence: true
  validates :instance_id, presence: true, uniqueness: true
  validates :instance_type, presence: true
  validates :status, inclusion: { in: INSTANCE_STATUSES }

  scope :running, -> { where(status: "running") }
  scope :stopped, -> { where(status: "stopped") }
  scope :by_provider, ->(provider_id) { where(cloud_provider_id: provider_id) }
  scope :recent, -> { order(created_at: :desc) }
  scope :by_region, ->(region) { joins(:cloud_provider).where(cloud_providers: { region: region }) }

  # ── Status ───────────────────────────────────────────────────
  def running?;   status == "running"; end
  def stopped?;   status == "stopped"; end
  def terminated?; status == "terminated"; end

  def provision!;  update!(status: "provisioning", provisioned_at: Time.now); end

  # ── Billing ──────────────────────────────────────────────────
  def daily_cost;  (hourly_cost || 0) * 24; end
  def monthly_cost; daily_cost * 30; end
  def display_status; status.humanize; end

  # ── Instance Specs (simulated from instance_type) ────────────
  def vcpus
    case instance_type
    when /t3\.nano|t3\.micro/ then 2
    when /t3\.small|t3\.medium/ then 2
    when /t3\.large/ then 2
    when /c5\.large/ then 2
    when /c5\.xlarge/ then 4
    when /c5\.2xlarge/ then 8
    when /m5\.large/ then 2
    when /m5\.xlarge/ then 4
    else 2
    end
  end

  def memory_gb
    case instance_type
    when /nano/ then 0.5
    when /micro/ then 1
    when /small/ then 2
    when /medium/ then 4
    when /large/ then 8
    when /xlarge/ then 16
    when /2xlarge/ then 32
    else 4
    end
  end

  # ── Simulated Monitoring (CPU/Memory/Disk %) ─────────────────
  def cpu_usage
    running? ? rand(5..85) : 0
  end

  def memory_usage
    running? ? rand(10..90) : 0
  end

  def disk_usage
    rand(20..80)
  end

  def network_in_mbps
    running? ? rand(0.1..500.0).round(1) : 0
  end

  def network_out_mbps
    running? ? rand(0.1..300.0).round(1) : 0
  end

  def uptime_hours
    return 0 unless provisioned_at
    ((terminated_at || Time.now) - provisioned_at) / 3600
  end
end
