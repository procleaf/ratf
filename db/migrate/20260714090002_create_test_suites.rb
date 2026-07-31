class CreateTestSuites < ActiveRecord::Migration[8.1]
  def change
    create_table :test_suites do |t|
      t.references :project, foreign_key: true
      t.string :name, null: false
      t.string :version
      t.integer :status, default: 0
      t.json :metadata, default: {}
      t.timestamps
    end

    add_index :test_suites, :status
    add_index :test_suites, [:name, :version], unique: true
  end
end
