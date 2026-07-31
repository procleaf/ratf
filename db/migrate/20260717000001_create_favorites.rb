class CreateFavorites < ActiveRecord::Migration[8.1]
  def change
    create_table :favorites do |t|
      t.references :user, null: false, foreign_key: true
      t.references :test_case, null: false, foreign_key: true
      t.timestamps
    end

    add_index :favorites, [:user_id, :test_case_id], unique: true
  end
end
