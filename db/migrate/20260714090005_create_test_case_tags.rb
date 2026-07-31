class CreateTestCaseTags < ActiveRecord::Migration[8.1]
  def change
    create_table :test_case_tags do |t|
      t.references :test_case, null: false, foreign_key: true
      t.references :tag, null: false, foreign_key: true
      t.timestamps
    end

    add_index :test_case_tags, [:test_case_id, :tag_id], unique: true
  end
end
