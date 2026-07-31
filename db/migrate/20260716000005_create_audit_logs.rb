class CreateAuditLogs < ActiveRecord::Migration[8.1]
  def change
    create_table :audit_logs do |t|
      t.references :user, foreign_key: true
      t.string :action, null: false        # create, update, destroy, login, logout
      t.string :auditable_type             # model name
      t.bigint :auditable_id               # model id
      t.json :changes_made, default: {}    # what changed
      t.string :ip_address
      t.string :user_agent
      t.timestamps
    end

    add_index :audit_logs, [:auditable_type, :auditable_id]
    add_index :audit_logs, :action
    add_index :audit_logs, :created_at
  end
end
