# db/migrate/20240101000000_create_users.rb
class CreateUserTable < ActiveRecord::Migration[8.1]

  def change
    create_table :users do |t|
      t.string :email, null: false
      t.string :username, null: false
      t.string :password_digest
      t.integer :role, default: 0
      t.string :api_token
      t.datetime :last_active_at
      t.json :preferences, default: {}
      
      t.timestamps
    end
    
    add_index :users, :email, unique: true
    add_index :users, :username, unique: true
    add_index :users, :api_token, unique: true
  end
 
end
