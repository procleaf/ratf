class CreateLogComments < ActiveRecord::Migration[8.1]
  def change
    create_table :log_comments do |t|
      t.references :log, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.text :content, null: false
      t.timestamps
    end
    add_index :log_comments, [:log_id, :created_at]
  end
end
