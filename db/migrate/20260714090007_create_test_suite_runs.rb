class CreateTestSuiteRuns < ActiveRecord::Migration[8.1]
  def change
    create_table :test_suite_runs do |t|
      t.references :test_suite, null: false, foreign_key: true
      t.references :job_run, null: false, foreign_key: true
      t.integer :status, default: 0
      t.integer :total_tests, default: 0
      t.integer :passed_tests, default: 0
      t.integer :failed_tests, default: 0
      t.integer :skipped_tests, default: 0
      t.integer :errored_tests, default: 0
      t.float :total_duration
      t.datetime :started_at
      t.datetime :ended_at
      t.timestamps
    end

    add_index :test_suite_runs, [:test_suite_id, :job_run_id], unique: true
    add_index :test_suite_runs, :status
  end
end
