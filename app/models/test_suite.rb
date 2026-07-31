class TestSuite < ActiveRecord::Base

  belongs_to :project, optional: true
  has_many :test_cases, dependent: :destroy
  has_many :test_results, through: :test_cases
  has_many :test_suite_runs, dependent: :destroy
  
  enum :status, { active: 0, maintenance: 1, deprecated: 2 }
  
  store_accessor :metadata, :description, :author, :tags, :dependencies
  
  validates :name, presence: true, uniqueness: { scope: :version }
  validates :version, format: { with: /\A\d+\.\d+\.\d+\z/ }, allow_blank: true
  
  scope :by_tag, ->(tag) { where("metadata->>'tags' LIKE ?", "%#{tag}%") }
  scope :recently_updated, -> { where('updated_at > ?', 7.days.ago) }
  
  def success_rate
    return 0 if test_results.empty?
    (test_results.passed.count.to_f / test_results.count * 100).round(2)
  end
  
  def total_test_cases
    test_cases.active.count
  end
  
  def last_run
    test_suite_runs.order(created_at: :desc).first
  end
  
  def average_duration
    test_results.average(:execution_time)&.round(3)
  end
  
  def flaky_test_cases
    test_cases
      .joins(:test_results)
      .group('test_cases.id')
      .having('COUNT(test_results.id) > ?', 5)
      .select('test_cases.*')
  end
  
  def to_yaml(source: false)
    hash = {
      name: name,
      description: metadata&.dig('description'),
      version: version,
      tags: metadata&.dig('tags'),
      test_cases: test_cases.active.map { |tc| tc.to_yaml_hash }
    }
    source ? hash.to_yaml : hash.to_yaml
  end

  # Export to downloadable YAML string
  def export_yaml
    to_yaml
  end

  # Import test cases from YAML string
  def import_from_yaml!(yaml_string, user: nil)
    data = YAML.safe_load(yaml_string, permitted_classes: [Symbol])
    return false unless data.is_a?(Hash)

    count = 0
    Array(data["test_cases"]).each do |tc_data|
      next unless tc_data.is_a?(Hash)
      test_cases.create!(
        name: tc_data["name"] || "Imported Test Case",
        description: tc_data["description"],
        test_type: tc_data["type"] || "functional",
        priority: tc_data["priority"] || "medium",
        created_by: user,
        definition: {
          steps: Array(tc_data["steps"]),
          preconditions: Array(tc_data["preconditions"]),
          expected_results: Array(tc_data["expected_results"]),
          data: tc_data["data"] || {}
        }
      )
      count += 1
    end
    count
  end

  # Clone this suite with all test cases
  def clone_with_cases!(name:, user: nil)
    new_suite = self.class.create!(
      name: name,
      version: version,
      project: project,
      status: :active,
      metadata: metadata
    )
    test_cases.each do |tc|
      new_suite.test_cases.create!(
        name: tc.name,
        description: tc.description,
        test_type: tc.test_type,
        priority: tc.priority,
        created_by: user,
        definition: tc.definition,
        status: :draft
      )
    end
    new_suite
  end
end


