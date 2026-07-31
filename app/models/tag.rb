class Tag < ActiveRecord::Base
  has_many :test_case_tags, dependent: :destroy
  has_many :test_cases, through: :test_case_tags

  validates :name, presence: true, uniqueness: true

  scope :by_name, ->(name) { where('name LIKE ?', "%#{name}%") }
end
