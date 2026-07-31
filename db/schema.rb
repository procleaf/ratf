# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_07_25_000004) do
  create_table "active_storage_attachments", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.bigint "record_id", null: false
    t.string "record_type", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.string "content_type"
    t.datetime "created_at", null: false
    t.string "filename", null: false
    t.string "key", null: false
    t.text "metadata"
    t.string "service_name", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "api_tokens", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "expires_at"
    t.datetime "last_used_at"
    t.string "name", null: false
    t.string "token_digest", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["token_digest"], name: "index_api_tokens_on_token_digest", unique: true
    t.index ["user_id"], name: "index_api_tokens_on_user_id"
  end

  create_table "audit_logs", force: :cascade do |t|
    t.string "action", null: false
    t.bigint "auditable_id"
    t.string "auditable_type"
    t.json "changes_made", default: {}
    t.datetime "created_at", null: false
    t.string "ip_address"
    t.datetime "updated_at", null: false
    t.string "user_agent"
    t.integer "user_id"
    t.index ["action"], name: "index_audit_logs_on_action"
    t.index ["auditable_type", "auditable_id"], name: "index_audit_logs_on_auditable_type_and_auditable_id"
    t.index ["created_at"], name: "index_audit_logs_on_created_at"
    t.index ["user_id"], name: "index_audit_logs_on_user_id"
  end

  create_table "cloud_instances", force: :cascade do |t|
    t.string "availability_zone"
    t.integer "cloud_provider_id", null: false
    t.datetime "created_at", null: false
    t.decimal "hourly_cost", precision: 8, scale: 4
    t.string "instance_id", null: false
    t.string "instance_type", null: false
    t.string "name", null: false
    t.string "private_ip"
    t.datetime "provisioned_at"
    t.string "public_ip"
    t.string "status", default: "provisioning"
    t.json "tags", default: {}
    t.datetime "terminated_at"
    t.datetime "updated_at", null: false
    t.integer "worker_id"
    t.index ["cloud_provider_id"], name: "index_cloud_instances_on_cloud_provider_id"
    t.index ["instance_id"], name: "index_cloud_instances_on_instance_id", unique: true
    t.index ["status"], name: "index_cloud_instances_on_status"
    t.index ["worker_id"], name: "index_cloud_instances_on_worker_id"
  end

  create_table "cloud_providers", force: :cascade do |t|
    t.json "config", default: {}
    t.datetime "created_at", null: false
    t.text "credentials_ciphertext"
    t.boolean "enabled", default: true
    t.datetime "last_verified_at"
    t.string "name", null: false
    t.string "provider_type", null: false
    t.string "region", null: false
    t.string "status", default: "pending"
    t.datetime "updated_at", null: false
    t.integer "user_id"
    t.index ["provider_type"], name: "index_cloud_providers_on_provider_type"
    t.index ["status"], name: "index_cloud_providers_on_status"
    t.index ["user_id"], name: "index_cloud_providers_on_user_id"
  end

  create_table "comment_reactions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "emoji", null: false
    t.integer "issue_comment_id", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["issue_comment_id", "user_id", "emoji"], name: "index_comment_reactions_on_comment_user_emoji", unique: true
    t.index ["issue_comment_id"], name: "index_comment_reactions_on_issue_comment_id"
    t.index ["user_id"], name: "index_comment_reactions_on_user_id"
  end

  create_table "favorites", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "test_case_id", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["test_case_id"], name: "index_favorites_on_test_case_id"
    t.index ["user_id", "test_case_id"], name: "index_favorites_on_user_id_and_test_case_id", unique: true
    t.index ["user_id"], name: "index_favorites_on_user_id"
  end

  create_table "issue_attachments", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "issue_id", null: false
    t.datetime "updated_at", null: false
    t.index ["issue_id"], name: "index_issue_attachments_on_issue_id"
  end

  create_table "issue_comments", force: :cascade do |t|
    t.text "content", null: false
    t.datetime "created_at", null: false
    t.integer "issue_id", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["issue_id", "created_at"], name: "index_issue_comments_on_issue_id_and_created_at"
    t.index ["issue_id"], name: "index_issue_comments_on_issue_id"
    t.index ["user_id"], name: "index_issue_comments_on_user_id"
  end

  create_table "issues", force: :cascade do |t|
    t.integer "assigned_to_id"
    t.datetime "closed_at"
    t.datetime "created_at", null: false
    t.text "description", null: false
    t.integer "issue_type", default: 0
    t.integer "reported_by_id", null: false
    t.integer "severity", default: 0
    t.integer "status", default: 0
    t.integer "test_case_id"
    t.integer "test_result_id"
    t.string "title", null: false
    t.datetime "updated_at", null: false
    t.integer "urgency", default: 0
    t.index ["assigned_to_id"], name: "index_issues_on_assigned_to_id"
    t.index ["reported_by_id"], name: "index_issues_on_reported_by_id"
    t.index ["severity"], name: "index_issues_on_severity"
    t.index ["status"], name: "index_issues_on_status"
    t.index ["test_case_id"], name: "index_issues_on_test_case_id"
    t.index ["test_result_id"], name: "index_issues_on_test_result_id"
  end

  create_table "job_artifacts", force: :cascade do |t|
    t.integer "artifact_type", default: 0
    t.datetime "created_at", null: false
    t.integer "job_id", null: false
    t.string "name", null: false
    t.datetime "updated_at", null: false
    t.index ["artifact_type"], name: "index_job_artifacts_on_artifact_type"
    t.index ["job_id"], name: "index_job_artifacts_on_job_id"
  end

  create_table "job_runs", force: :cascade do |t|
    t.datetime "completed_at"
    t.datetime "created_at", null: false
    t.integer "job_id", null: false
    t.datetime "started_at"
    t.integer "status", default: 0
    t.datetime "updated_at", null: false
    t.integer "worker_id"
    t.index ["job_id", "status"], name: "index_job_runs_on_job_id_and_status"
    t.index ["job_id"], name: "index_job_runs_on_job_id"
    t.index ["status"], name: "index_job_runs_on_status"
    t.index ["worker_id"], name: "index_job_runs_on_worker_id"
  end

  create_table "jobs", force: :cascade do |t|
    t.datetime "completed_at"
    t.datetime "created_at", null: false
    t.integer "created_by_id"
    t.json "definition", default: {}
    t.text "description"
    t.string "name", null: false
    t.integer "priority", default: 1
    t.datetime "started_at"
    t.integer "status", default: 0
    t.datetime "updated_at", null: false
    t.index ["created_by_id", "status"], name: "index_jobs_on_created_by_id_and_status"
    t.index ["created_by_id"], name: "index_jobs_on_created_by_id"
    t.index ["status"], name: "index_jobs_on_status"
  end

  create_table "log_comments", force: :cascade do |t|
    t.text "content", null: false
    t.datetime "created_at", null: false
    t.integer "log_id", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["log_id", "created_at"], name: "index_log_comments_on_log_id_and_created_at"
    t.index ["log_id"], name: "index_log_comments_on_log_id"
    t.index ["user_id"], name: "index_log_comments_on_user_id"
  end

  create_table "log_entries", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "job_run_id"
    t.integer "log_level", default: 0
    t.text "message", null: false
    t.json "metadata", default: {}
    t.string "source"
    t.integer "test_case_id"
    t.datetime "timestamp"
    t.datetime "updated_at", null: false
    t.index ["job_run_id"], name: "index_log_entries_on_job_run_id"
    t.index ["log_level"], name: "index_log_entries_on_log_level"
    t.index ["test_case_id"], name: "index_log_entries_on_test_case_id"
    t.index ["timestamp"], name: "index_log_entries_on_timestamp"
  end

  create_table "logs", force: :cascade do |t|
    t.text "content", null: false
    t.datetime "created_at", null: false
    t.integer "job_run_id"
    t.datetime "updated_at", null: false
    t.index ["created_at"], name: "index_logs_on_created_at"
    t.index ["job_run_id"], name: "index_logs_on_job_run_id"
  end

  create_table "notifications", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "message", null: false
    t.integer "notification_type", default: 0
    t.datetime "read_at"
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["notification_type"], name: "index_notifications_on_notification_type"
    t.index ["user_id", "read_at"], name: "index_notifications_on_user_id_and_read_at"
    t.index ["user_id"], name: "index_notifications_on_user_id"
  end

  create_table "posts", force: :cascade do |t|
    t.text "content"
    t.datetime "created_at", null: false
    t.string "title"
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["created_at"], name: "index_posts_on_created_at"
    t.index ["user_id"], name: "index_posts_on_user_id"
  end

  create_table "projects", force: :cascade do |t|
    t.datetime "archived_at"
    t.datetime "created_at", null: false
    t.text "description"
    t.string "name", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_projects_on_name", unique: true
  end

  create_table "schedules", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "cron_expression", null: false
    t.text "description"
    t.boolean "enabled", default: true
    t.integer "job_id", null: false
    t.datetime "last_run_at"
    t.string "name", null: false
    t.datetime "next_run_at"
    t.integer "run_count", default: 0
    t.datetime "updated_at", null: false
    t.index ["job_id"], name: "index_schedules_on_job_id"
  end

  create_table "tags", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_tags_on_name", unique: true
  end

  create_table "test_case_tags", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "tag_id", null: false
    t.integer "test_case_id", null: false
    t.datetime "updated_at", null: false
    t.index ["tag_id"], name: "index_test_case_tags_on_tag_id"
    t.index ["test_case_id", "tag_id"], name: "index_test_case_tags_on_test_case_id_and_tag_id", unique: true
    t.index ["test_case_id"], name: "index_test_case_tags_on_test_case_id"
  end

  create_table "test_cases", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "created_by_id"
    t.json "definition", default: {}
    t.text "description"
    t.string "name", null: false
    t.integer "priority", default: 0
    t.integer "status", default: 0
    t.integer "test_suite_id", null: false
    t.integer "test_type", default: 0
    t.datetime "updated_at", null: false
    t.index ["created_by_id"], name: "index_test_cases_on_created_by_id"
    t.index ["status"], name: "index_test_cases_on_status"
    t.index ["test_suite_id", "name"], name: "index_test_cases_on_test_suite_id_and_name", unique: true
    t.index ["test_suite_id"], name: "index_test_cases_on_test_suite_id"
    t.index ["test_type"], name: "index_test_cases_on_test_type"
  end

  create_table "test_results", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "ended_at"
    t.float "execution_time"
    t.integer "job_run_id"
    t.text "message"
    t.json "metadata", default: {}
    t.string "name", null: false
    t.datetime "started_at"
    t.integer "status", default: 0
    t.integer "test_case_id"
    t.integer "test_suite_id"
    t.datetime "updated_at", null: false
    t.index ["job_run_id"], name: "index_test_results_on_job_run_id"
    t.index ["status"], name: "index_test_results_on_status"
    t.index ["test_case_id"], name: "index_test_results_on_test_case_id"
    t.index ["test_suite_id", "status"], name: "index_test_results_on_test_suite_id_and_status"
    t.index ["test_suite_id"], name: "index_test_results_on_test_suite_id"
  end

  create_table "test_suite_runs", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "ended_at"
    t.integer "errored_tests", default: 0
    t.integer "failed_tests", default: 0
    t.integer "job_run_id", null: false
    t.integer "passed_tests", default: 0
    t.integer "skipped_tests", default: 0
    t.datetime "started_at"
    t.integer "status", default: 0
    t.integer "test_suite_id", null: false
    t.float "total_duration"
    t.integer "total_tests", default: 0
    t.datetime "updated_at", null: false
    t.index ["job_run_id"], name: "index_test_suite_runs_on_job_run_id"
    t.index ["status"], name: "index_test_suite_runs_on_status"
    t.index ["test_suite_id", "job_run_id"], name: "index_test_suite_runs_on_test_suite_id_and_job_run_id", unique: true
    t.index ["test_suite_id"], name: "index_test_suite_runs_on_test_suite_id"
  end

  create_table "test_suites", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.json "metadata", default: {}
    t.string "name", null: false
    t.integer "project_id"
    t.integer "status", default: 0
    t.datetime "updated_at", null: false
    t.string "version"
    t.index ["name", "version"], name: "index_test_suites_on_name_and_version", unique: true
    t.index ["project_id"], name: "index_test_suites_on_project_id"
    t.index ["status"], name: "index_test_suites_on_status"
  end

  create_table "user_preferences", force: :cascade do |t|
    t.boolean "comment_notify", default: true
    t.datetime "created_at", null: false
    t.boolean "email_notifications", default: true
    t.boolean "issue_notify", default: true
    t.integer "items_per_page", default: 25
    t.boolean "job_completed_notify", default: true
    t.boolean "job_failed_notify", default: true
    t.string "locale", default: "en"
    t.string "theme", default: "system"
    t.json "ui_preferences", default: {}
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["user_id"], name: "index_user_preferences_on_user_id", unique: true
  end

  create_table "user_stats", force: :cascade do |t|
    t.integer "api_tokens_count", default: 0
    t.integer "comments_count", default: 0
    t.datetime "created_at", null: false
    t.integer "days_visited", default: 0
    t.datetime "first_job_created_at"
    t.integer "issues_reported_count", default: 0
    t.integer "issues_resolved_count", default: 0
    t.integer "jobs_completed_count", default: 0
    t.integer "jobs_created_count", default: 0
    t.integer "jobs_failed_count", default: 0
    t.datetime "last_job_created_at"
    t.integer "posts_count", default: 0
    t.integer "test_cases_count", default: 0
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["user_id"], name: "index_user_stats_on_user_id", unique: true
  end

  create_table "user_subscriptions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "issue_id", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["issue_id"], name: "index_user_subscriptions_on_issue_id"
    t.index ["user_id", "issue_id"], name: "index_user_subscriptions_on_user_id_and_issue_id", unique: true
    t.index ["user_id"], name: "index_user_subscriptions_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "api_token"
    t.datetime "created_at", null: false
    t.string "email", null: false
    t.datetime "last_active_at"
    t.string "password_digest"
    t.json "preferences", default: {}
    t.integer "role", default: 0
    t.datetime "updated_at", null: false
    t.string "username", null: false
    t.index ["api_token"], name: "index_users_on_api_token", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["username"], name: "index_users_on_username", unique: true
  end

  create_table "wiki_pages", force: :cascade do |t|
    t.integer "author_id"
    t.text "body", null: false
    t.datetime "created_at", null: false
    t.string "tags"
    t.string "title", null: false
    t.datetime "updated_at", null: false
    t.index ["author_id"], name: "index_wiki_pages_on_author_id"
    t.index ["tags"], name: "index_wiki_pages_on_tags"
    t.index ["title"], name: "index_wiki_pages_on_title", unique: true
  end

  create_table "workers", force: :cascade do |t|
    t.json "capabilities", default: []
    t.datetime "created_at", null: false
    t.string "host", null: false
    t.datetime "last_heartbeat_at"
    t.string "name", null: false
    t.integer "parallel_jobs", default: 1
    t.integer "status", default: 0
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_workers_on_name", unique: true
    t.index ["status"], name: "index_workers_on_status"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "api_tokens", "users"
  add_foreign_key "audit_logs", "users"
  add_foreign_key "cloud_instances", "cloud_providers"
  add_foreign_key "cloud_instances", "workers"
  add_foreign_key "cloud_providers", "users"
  add_foreign_key "comment_reactions", "issue_comments"
  add_foreign_key "comment_reactions", "users"
  add_foreign_key "favorites", "test_cases"
  add_foreign_key "favorites", "users"
  add_foreign_key "issue_attachments", "issues"
  add_foreign_key "issue_comments", "issues"
  add_foreign_key "issue_comments", "users"
  add_foreign_key "issues", "test_cases"
  add_foreign_key "issues", "test_results"
  add_foreign_key "issues", "users", column: "assigned_to_id"
  add_foreign_key "issues", "users", column: "reported_by_id"
  add_foreign_key "job_artifacts", "jobs"
  add_foreign_key "job_runs", "jobs"
  add_foreign_key "job_runs", "workers"
  add_foreign_key "jobs", "users", column: "created_by_id"
  add_foreign_key "log_comments", "logs"
  add_foreign_key "log_comments", "users"
  add_foreign_key "log_entries", "job_runs"
  add_foreign_key "log_entries", "test_cases"
  add_foreign_key "logs", "job_runs"
  add_foreign_key "notifications", "users"
  add_foreign_key "posts", "users"
  add_foreign_key "schedules", "jobs"
  add_foreign_key "test_case_tags", "tags"
  add_foreign_key "test_case_tags", "test_cases"
  add_foreign_key "test_cases", "test_suites"
  add_foreign_key "test_cases", "users", column: "created_by_id"
  add_foreign_key "test_results", "job_runs"
  add_foreign_key "test_results", "test_cases"
  add_foreign_key "test_results", "test_suites"
  add_foreign_key "test_suite_runs", "job_runs"
  add_foreign_key "test_suite_runs", "test_suites"
  add_foreign_key "test_suites", "projects"
  add_foreign_key "user_preferences", "users"
  add_foreign_key "user_stats", "users"
  add_foreign_key "user_subscriptions", "issues"
  add_foreign_key "user_subscriptions", "users"
  add_foreign_key "wiki_pages", "users", column: "author_id"
end
