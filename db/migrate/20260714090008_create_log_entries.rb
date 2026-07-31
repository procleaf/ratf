class CreateLogEntries < ActiveRecord::Migration[8.1]
  def change
    create_table :log_entries do |t|
      t.references :job_run, foreign_key: true
      t.references :test_case, foreign_key: true
      t.integer :log_level, default: 0
      t.text :message, null: false
      t.string :source
      t.datetime :timestamp
      t.json :metadata, default: {}
      t.timestamps
    end

    add_index :log_entries, :log_level
    add_index :log_entries, :timestamp
  end
end
