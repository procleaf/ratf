class TestCaseTag < ActiveRecord::Base
  belongs_to :test_case
  belongs_to :tag

  validates :test_case_id, uniqueness: { scope: :tag_id }
end
