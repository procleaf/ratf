class CreateIssues < ActiveRecord::Migration[8.1]
  def change
    create_table :issues do |t|
      t.references :test_case, foreign_key: true
      t.references :test_result, foreign_key: true
      t.references :reported_by, null: false, foreign_key: { to_table: :users }
      t.references :assigned_to, foreign_key: { to_table: :users }
      t.string :title, null: false
      t.text :description, null: false
      t.integer :status, default: 0
      t.integer :severity, default: 0
      t.integer :urgency, default: 0
      t.integer :issue_type, default: 0
      t.datetime :closed_at
      t.timestamps
    end

    add_index :issues, :status
    add_index :issues, :severity
  end
end
