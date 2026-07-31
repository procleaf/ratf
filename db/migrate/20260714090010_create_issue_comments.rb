class CreateIssueComments < ActiveRecord::Migration[8.1]
  def change
    create_table :issue_comments do |t|
      t.references :issue, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.text :content, null: false
      t.timestamps
    end

    add_index :issue_comments, [:issue_id, :created_at]
  end
end
