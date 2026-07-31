class CreateJobRuns < ActiveRecord::Migration[8.1]
  def change
    create_table :job_runs do |t|
      t.references :job, null: false, foreign_key: true
      t.references :worker, foreign_key: true
      t.integer :status, default: 0
      t.datetime :started_at
      t.datetime :completed_at
      t.timestamps
    end

    add_index :job_runs, :status
    add_index :job_runs, [:job_id, :status]
  end
end
