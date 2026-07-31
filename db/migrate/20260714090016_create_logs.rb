class CreateLogs < ActiveRecord::Migration[8.1]
  def change
    create_table :logs do |t|
      t.references :job_run, foreign_key: true
      t.text :content, null: false
      t.timestamps
    end

    add_index :logs, :created_at
  end
end
