class CloudProvider < ActiveRecord::Base
  belongs_to :user, optional: true
  has_many :cloud_instances, dependent: :restrict_with_error

  PROVIDER_TYPES = %w[aws gcp azure private aliyun].freeze

  validates :name, presence: true, uniqueness: true
  validates :provider_type, presence: true, inclusion: { in: PROVIDER_TYPES }
  validates :region, presence: true

  scope :enabled, -> { where(enabled: true) }
  scope :by_type, ->(type) { where(provider_type: type) }
  scope :aliyun, -> { where(provider_type: "aliyun") }
  scope :connected, -> { where(status: "connected") }

  def connected?
    status == "connected"
  end

  def verify!
    # Simulated connection check — in production this would probe the cloud API
    self.last_verified_at = Time.now
    self.status = "connected"
    save!
  rescue => e
    self.status = "error"
    save!
  end

  def active_instances
    cloud_instances.where(status: %w[provisioning running])
  end

  def monthly_estimated_cost
    cloud_instances.where(status: "running").sum(:hourly_cost) * 730
  end

  def instance_count_by_status
    cloud_instances.group(:status).count
  end

  def display_name
    "#{name} (#{provider_type.upcase} — #{region})"
  end
end
