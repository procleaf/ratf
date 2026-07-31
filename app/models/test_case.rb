class TestCase < ActiveRecord::Base

  belongs_to :test_suite
  belongs_to :created_by, class_name: 'User'
  has_many :test_results, dependent: :destroy
  has_many :test_case_tags, dependent: :destroy
  has_many :tags, through: :test_case_tags
  has_many :favorites, dependent: :destroy
  has_many :favorited_by, through: :favorites, source: :user
  
  # Store test case definition
  store_accessor :definition, :steps, :preconditions, :expected_results, :data, :capabilities
  
  enum :status, { draft: 0, active: 1, deprecated: 2, archived: 3 }
  enum :priority, { low: 0, medium: 1, high: 2, critical: 3 }
  enum :test_type, { functional: 0, performance: 1, security: 2, integration: 3, acceptance: 4, browser: 5, mobile: 6, natural_language: 7 }
  
  validates :name, presence: true, uniqueness: { scope: :test_suite_id }
  validates :test_type, presence: true
  
  scope :active_test_cases, -> { where(status: :active) }
  scope :by_priority, ->(priority) { where(priority: priority) }
  scope :by_tag, ->(tag_name) { joins(:tags).where(tags: { name: tag_name }) }
  
  # Calculate statistics
  def success_rate
    return 0 if test_results.empty?
    (test_results.passed.count.to_f / test_results.count * 100).round(2)
  end
  
  def last_execution
    test_results.order(created_at: :desc).first
  end
  
  def average_execution_time
    test_results.average(:execution_time)&.round(3)
  end
  
  def flaky?
    return false if test_results.count < 5
    success_rate < 80 && success_rate > 20
  end
  
  def human_readable_status
    {
      draft: 'Draft',
      active: 'Active',
      deprecated: 'Deprecated',
      archived: 'Archived'
    }[status.to_sym]
  end
  
  def to_yaml_hash
    {
      name: name,
      description: description,
      type: test_type,
      priority: priority,
      preconditions: definition&.dig('preconditions'),
      steps: definition&.dig('steps'),
      expected_results: definition&.dig('expected_results')
    }
  end

  def to_yaml
    to_yaml_hash.to_yaml
  end
end
