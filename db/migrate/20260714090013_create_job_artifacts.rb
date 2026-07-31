class CreateJobArtifacts < ActiveRecord::Migration[8.1]
  def change
    create_table :job_artifacts do |t|
      t.references :job, null: false, foreign_key: true
      t.string :name, null: false
      t.integer :artifact_type, default: 0
      t.timestamps
    end

    add_index :job_artifacts, :artifact_type
  end
end
