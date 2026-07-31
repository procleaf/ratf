class AddUserToCloudProviders < ActiveRecord::Migration[8.1]
  def change
    add_reference :cloud_providers, :user, foreign_key: true
  end
end
