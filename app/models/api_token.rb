class ApiToken < ApplicationRecord
  belongs_to :user

  attr_accessor :raw_token

  validates :name, presence: true

  before_create :generate_token

  scope :active, -> { where("expires_at IS NULL OR expires_at > ?", Time.current) }

  def expired?
    expires_at.present? && expires_at <= Time.current
  end

  def record_usage!
    update!(last_used_at: Time.current)
  end

  private

  def generate_token
    self.raw_token = SecureRandom.hex(32)
    self.token_digest = BCrypt::Password.create(raw_token)
  end
end
