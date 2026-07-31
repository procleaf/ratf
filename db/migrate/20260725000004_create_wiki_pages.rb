class CreateWikiPages < ActiveRecord::Migration[8.1]
  def change
    create_table :wiki_pages do |t|
      t.string :title, null: false
      t.text :body, null: false
      t.references :author, foreign_key: { to_table: :users }
      t.string :tags
      t.timestamps
    end
    add_index :wiki_pages, :title, unique: true
    add_index :wiki_pages, :tags
  end
end
