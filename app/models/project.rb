class Project < ActiveRecord::Base
  has_many :test_suites, dependent: :nullify

  validates :name, presence: true, uniqueness: true

  scope :active, -> { where(archived_at: nil) }
  scope :archived, -> { where.not(archived_at: nil) }

  def archive!
    update!(archived_at: Time.now)
  end

  def archived?
    archived_at.present?
  end
end
