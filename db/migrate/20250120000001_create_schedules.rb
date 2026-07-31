class CreateSchedules < ActiveRecord::Migration[8.1]
  def change
    create_table :schedules do |t|
      t.references :job, null: false, foreign_key: true
      t.string :name, null: false
      t.string :cron_expression, null: false
      t.boolean :enabled, default: true
      t.text :description
      t.datetime :last_run_at
      t.datetime :next_run_at
      t.integer :run_count, default: 0
      t.timestamps
    end
  end
end
