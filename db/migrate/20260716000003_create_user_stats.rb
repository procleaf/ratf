class CreateUserStats < ActiveRecord::Migration[8.1]
  def change
    create_table :user_stats do |t|
      t.references :user, null: false, foreign_key: true, index: { unique: true }
      t.integer :jobs_created_count, default: 0
      t.integer :jobs_completed_count, default: 0
      t.integer :jobs_failed_count, default: 0
      t.integer :test_cases_count, default: 0
      t.integer :issues_reported_count, default: 0
      t.integer :issues_resolved_count, default: 0
      t.integer :api_tokens_count, default: 0
      t.integer :comments_count, default: 0
      t.integer :posts_count, default: 0
      t.integer :days_visited, default: 0
      t.datetime :first_job_created_at
      t.datetime :last_job_created_at
      t.timestamps
    end
  end
end
