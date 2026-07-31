class CreateCloudProviders < ActiveRecord::Migration[8.1]
  def change
    create_table :cloud_providers do |t|
      t.string :name, null: false
      t.string :provider_type, null: false  # aws, gcp, azure, private
      t.string :region, null: false
      t.text :credentials_ciphertext        # encrypted credentials JSON
      t.json :config, default: {}           # provider-specific config
      t.boolean :enabled, default: true
      t.string :status, default: "pending"  # pending, connected, error, disabled
      t.datetime :last_verified_at
      t.timestamps
    end

    add_index :cloud_providers, :provider_type
    add_index :cloud_providers, :status
  end
end
