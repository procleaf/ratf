class CreateTestResults < ActiveRecord::Migration[8.1]
  def change
    create_table :test_results do |t|
      t.references :job_run, foreign_key: true
      t.references :test_case, foreign_key: true
      t.references :test_suite, foreign_key: true
      t.string :name, null: false
      t.integer :status, default: 0
      t.float :execution_time
      t.text :message
      t.json :metadata, default: {}
      t.datetime :started_at
      t.datetime :ended_at
      t.timestamps
    end

    add_index :test_results, :status
    add_index :test_results, [:test_suite_id, :status]
  end
end
