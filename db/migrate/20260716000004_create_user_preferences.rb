class CreateUserPreferences < ActiveRecord::Migration[8.1]
  def change
    create_table :user_preferences do |t|
      t.references :user, null: false, foreign_key: true, index: { unique: true }
      t.string :theme, default: "system"       # light, dark, system
      t.string :locale, default: "en"           # en, zh
      t.boolean :email_notifications, default: true
      t.boolean :job_completed_notify, default: true
      t.boolean :job_failed_notify, default: true
      t.boolean :issue_notify, default: true
      t.boolean :comment_notify, default: true
      t.integer :items_per_page, default: 25
      t.json :ui_preferences, default: {}       # sidebar collapsed, etc.
      t.timestamps
    end
  end
end
