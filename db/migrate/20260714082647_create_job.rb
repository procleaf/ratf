class CreateJob < ActiveRecord::Migration[8.1]

  def change
    create_table :jobs do |t|
      t.string :name, null: false
      t.text :description
      t.integer :status, default: 0
      t.integer :priority, default: 1
      t.json :definition, default: {}
      t.references :created_by, foreign_key: { to_table: :users }
      t.datetime :started_at
      t.datetime :completed_at
      
      t.timestamps
    end
    
    add_index :jobs, :status
    add_index :jobs, [:created_by_id, :status]
  end

end
