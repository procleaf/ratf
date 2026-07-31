class CreateIssueAttachments < ActiveRecord::Migration[8.1]
  def change
    create_table :issue_attachments do |t|
      t.references :issue, null: false, foreign_key: true
      t.timestamps
    end
  end
end
