class IssueAttachment < ActiveRecord::Base
  belongs_to :issue

  has_one_attached :file

  validates :file, presence: true
end
