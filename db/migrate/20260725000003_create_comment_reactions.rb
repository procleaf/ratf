class CreateCommentReactions < ActiveRecord::Migration[8.1]
  def change
    create_table :comment_reactions do |t|
      t.references :issue_comment, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.string :emoji, null: false
      t.timestamps
    end
    add_index :comment_reactions, [:issue_comment_id, :user_id, :emoji], unique: true, name: "index_comment_reactions_on_comment_user_emoji"
  end
end
