class CreateUserSubscriptions < ActiveRecord::Migration[8.1]
  def change
    create_table :user_subscriptions do |t|
      t.references :user, null: false, foreign_key: true
      t.references :issue, null: false, foreign_key: true
      t.timestamps
    end

    add_index :user_subscriptions, [:user_id, :issue_id], unique: true
  end
end
