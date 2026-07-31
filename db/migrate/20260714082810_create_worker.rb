class CreateWorker < ActiveRecord::Migration[8.1]

  def change
    create_table :workers do |t|
      t.string :name, null: false
      t.string :host, null: false
      t.integer :status, default: 0
      t.integer :parallel_jobs, default: 1
      
      # Change from array to jsonb for better compatibility
      t.json :capabilities, default: []
      
      t.datetime :last_heartbeat_at
      
      t.timestamps
    end
    
    add_index :workers, :name, unique: true
    add_index :workers, :status
  end

end
