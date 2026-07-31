class CommentReaction < ActiveRecord::Base
  belongs_to :issue_comment
  belongs_to :user

  validates :emoji, presence: true
  validates :user_id, uniqueness: { scope: [:issue_comment_id, :emoji] }

  EMOJIS = {
    "👍" => "thumbs up",
    "😄" => "laugh",
    "🎉" => "celebrate",
    "🚀" => "rocket",
    "👀" => "eyes",
    "💯" => "hundred"
  }.freeze

  def self.emojis
    EMOJIS
  end
end
