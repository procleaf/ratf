# frozen_string_literal: true
# WikiPage — knowledge base article with Markdown body
class WikiPage < ActiveRecord::Base
  belongs_to :author, class_name: "User"

  validates :title, presence: true, uniqueness: true
  validates :body, presence: true

  scope :recent, -> { order(updated_at: :desc).limit(20) }
  scope :search, ->(q) { where("title LIKE ? OR body LIKE ?", "%#{q}%", "%#{q}%") }

  def excerpt(length = 200)
    body.to_s.truncate(length)
  end
end
