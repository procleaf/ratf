class CreateCloudInstances < ActiveRecord::Migration[8.1]
  def change
    create_table :cloud_instances do |t|
      t.references :cloud_provider, null: false, foreign_key: true
      t.references :worker, foreign_key: true
      t.string :instance_id, null: false        # cloud provider's instance ID
      t.string :instance_type, null: false       # e.g. t3.medium, e2-standard-2
      t.string :name, null: false
      t.string :status, default: "provisioning"  # provisioning, running, stopping, stopped, terminated, error
      t.string :public_ip
      t.string :private_ip
      t.string :availability_zone
      t.json :tags, default: {}
      t.datetime :provisioned_at
      t.datetime :terminated_at
      t.decimal :hourly_cost, precision: 8, scale: 4
      t.timestamps
    end

    add_index :cloud_instances, :status
    add_index :cloud_instances, :instance_id, unique: true
  end
end
