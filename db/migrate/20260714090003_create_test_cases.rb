class CreateTestCases < ActiveRecord::Migration[8.1]
  def change
    create_table :test_cases do |t|
      t.references :test_suite, null: false, foreign_key: true
      t.references :created_by, foreign_key: { to_table: :users }
      t.string :name, null: false
      t.text :description
      t.integer :status, default: 0
      t.integer :priority, default: 0
      t.integer :test_type, default: 0
      t.json :definition, default: {}
      t.timestamps
    end

    add_index :test_cases, :status
    add_index :test_cases, :test_type
    add_index :test_cases, [:test_suite_id, :name], unique: true
  end
end
