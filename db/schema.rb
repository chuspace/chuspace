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

ActiveRecord::Schema.define(version: 2021_12_11_122552) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "citext"
  enable_extension "pgcrypto"
  enable_extension "plpgsql"

  # Custom types defined in this database.
  # Note that some types may not work with other database engines. Be careful if changing database.
  create_enum "blog_repo_status_enum_type", ["syncing", "synced", "failed"]
  create_enum "blog_visibility_enum_type", ["private", "public", "subscriber"]
  create_enum "content_originator_enum_type", ["chuspace", "github", "gitlab"]
  create_enum "git_provider_enum_type", ["github", "gitlab"]
  create_enum "identity_provider_enum_type", ["email", "github", "gitlab", "bitbucket"]
  create_enum "invite_status_enum_type", ["pending", "expired", "joined"]
  create_enum "membership_role_enum_type", ["writer", "editor", "manager", "owner", "subscriber"]
  create_enum "post_visibility_enum_type", ["private", "public", "subscriber"]

  create_table "action_text_rich_texts", force: :cascade do |t|
    t.string "name", null: false
    t.text "body"
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["record_type", "record_id", "name"], name: "index_action_text_rich_texts_uniqueness", unique: true
  end

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", precision: 6, null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "blogs", force: :cascade do |t|
    t.string "name", null: false
    t.string "permalink", null: false
    t.text "description"
    t.bigint "owner_id", null: false
    t.bigint "git_provider_id", null: false
    t.boolean "personal", default: false, null: false
    t.string "repo_fullname", null: false
    t.string "repo_posts_folder", null: false
    t.string "repo_drafts_folder"
    t.string "repo_assets_folder", null: false
    t.string "repo_readme_path", default: "README.md"
    t.datetime "repo_last_synced_at"
    t.bigint "repo_webhook_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.enum "visibility", default: "private", null: false, enum_type: "blog_visibility_enum_type"
    t.enum "repo_status", default: "syncing", null: false, enum_type: "blog_repo_status_enum_type"
    t.index ["git_provider_id"], name: "index_blogs_on_git_provider_id"
    t.index ["owner_id"], name: "index_blogs_on_owner_id"
    t.index ["permalink", "owner_id"], name: "index_blogs_on_permalink_and_owner_id", unique: true
    t.index ["personal"], name: "index_blogs_on_personal"
  end

  create_table "editions", force: :cascade do |t|
    t.text "title", null: false
    t.text "summary", null: false
    t.bigint "publisher_id", null: false
    t.bigint "revision_id", null: false
    t.bigint "number", null: false
    t.datetime "published_at", precision: 6, null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["published_at"], name: "index_editions_on_published_at"
    t.index ["publisher_id"], name: "index_editions_on_publisher_id"
    t.index ["revision_id", "number"], name: "index_editions_on_revision_id_and_number", unique: true
    t.index ["revision_id"], name: "index_editions_on_revision_id"
  end

  create_table "friendly_id_slugs", force: :cascade do |t|
    t.string "slug", null: false
    t.bigint "sluggable_id", null: false
    t.string "sluggable_type", limit: 50
    t.string "scope"
    t.datetime "created_at", precision: 6
    t.index ["slug", "sluggable_type", "scope"], name: "index_friendly_id_slugs_on_slug_and_sluggable_type_and_scope", unique: true
    t.index ["slug", "sluggable_type"], name: "index_friendly_id_slugs_on_slug_and_sluggable_type"
    t.index ["sluggable_type", "sluggable_id"], name: "index_friendly_id_slugs_on_sluggable_type_and_sluggable_id"
  end

  create_table "git_providers", force: :cascade do |t|
    t.string "label", null: false
    t.text "access_token"
    t.text "refresh_access_token"
    t.text "endpoint"
    t.boolean "self_hosted", default: false, null: false
    t.bigint "user_id", null: false
    t.datetime "expires_at", precision: 6
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.enum "name", null: false, enum_type: "git_provider_enum_type"
    t.index ["user_id", "name"], name: "index_git_providers_on_user_id_and_name", unique: true
    t.index ["user_id"], name: "index_git_providers_on_user_id"
  end

  create_table "good_jobs", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.text "queue_name"
    t.bigint "priority"
    t.jsonb "serialized_params"
    t.datetime "scheduled_at"
    t.datetime "performed_at"
    t.datetime "finished_at"
    t.text "error"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.uuid "active_job_id"
    t.text "concurrency_key"
    t.text "cron_key"
    t.uuid "retried_good_job_id"
    t.datetime "cron_at"
    t.index ["active_job_id", "created_at"], name: "index_good_jobs_on_active_job_id_and_created_at"
    t.index ["concurrency_key"], name: "index_good_jobs_on_concurrency_key_when_unfinished", where: "(finished_at IS NULL)"
    t.index ["cron_key", "created_at"], name: "index_good_jobs_on_cron_key_and_created_at"
    t.index ["cron_key", "cron_at"], name: "index_good_jobs_on_cron_key_and_cron_at", unique: true
    t.index ["queue_name", "scheduled_at"], name: "index_good_jobs_on_queue_name_and_scheduled_at", where: "(finished_at IS NULL)"
    t.index ["scheduled_at"], name: "index_good_jobs_on_scheduled_at", where: "(finished_at IS NULL)"
  end

  create_table "identities", force: :cascade do |t|
    t.text "uid", null: false
    t.string "magic_auth_token", null: false
    t.datetime "magic_auth_token_expires_at"
    t.bigint "user_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.enum "provider", null: false, enum_type: "identity_provider_enum_type"
    t.index ["magic_auth_token"], name: "index_identities_on_magic_auth_token", unique: true
    t.index ["uid", "provider"], name: "index_identities_on_uid_and_provider", unique: true
    t.index ["user_id"], name: "index_identities_on_user_id"
  end

  create_table "invites", force: :cascade do |t|
    t.bigint "sender_id", null: false
    t.bigint "blog_id", null: false
    t.string "identifier", null: false
    t.text "code"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.enum "role", default: "writer", null: false, enum_type: "membership_role_enum_type"
    t.enum "status", default: "pending", null: false, enum_type: "invite_status_enum_type"
    t.index ["blog_id"], name: "index_invites_on_blog_id"
    t.index ["code"], name: "index_invites_on_code", unique: true
    t.index ["identifier", "blog_id"], name: "index_invites_on_identifier_and_blog_id", unique: true
    t.index ["identifier"], name: "index_invites_on_identifier"
    t.index ["role"], name: "index_invites_on_role"
    t.index ["sender_id"], name: "index_invites_on_sender_id"
    t.index ["status"], name: "index_invites_on_status"
  end

  create_table "memberships", force: :cascade do |t|
    t.bigint "blog_id", null: false
    t.bigint "user_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.enum "role", default: "writer", null: false, enum_type: "membership_role_enum_type"
    t.index ["blog_id"], name: "index_memberships_on_blog_id"
    t.index ["user_id"], name: "index_memberships_on_user_id"
  end

  create_table "posts", force: :cascade do |t|
    t.string "blob_path", null: false
    t.bigint "blog_id", null: false
    t.bigint "author_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.enum "visibility", default: "public", enum_type: "post_visibility_enum_type"
    t.enum "originator", default: "chuspace", null: false, enum_type: "content_originator_enum_type"
    t.index ["author_id"], name: "index_posts_on_author_id"
    t.index ["blob_path"], name: "index_posts_on_blob_path"
    t.index ["blog_id", "blob_path"], name: "index_posts_on_blog_id_and_blob_path", unique: true
    t.index ["blog_id"], name: "index_posts_on_blog_id"
  end

  create_table "revisions", force: :cascade do |t|
    t.bigint "post_id", null: false
    t.bigint "committer_id"
    t.jsonb "fallback_committer", default: {}, null: false
    t.text "message", default: "", null: false
    t.text "content", default: "", null: false
    t.text "sha", null: false
    t.bigint "number", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.enum "originator", default: "chuspace", null: false, enum_type: "content_originator_enum_type"
    t.index ["committer_id"], name: "index_revisions_on_committer_id"
    t.index ["number"], name: "index_revisions_on_number"
    t.index ["post_id", "number"], name: "index_revisions_on_post_id_and_number", unique: true
    t.index ["post_id"], name: "index_revisions_on_post_id"
    t.index ["sha"], name: "index_revisions_on_sha"
  end

  create_table "taggings", id: :serial, force: :cascade do |t|
    t.integer "tag_id"
    t.string "taggable_type"
    t.integer "taggable_id"
    t.string "tagger_type"
    t.integer "tagger_id"
    t.string "context", limit: 128
    t.datetime "created_at"
    t.string "tenant", limit: 128
    t.index ["context"], name: "index_taggings_on_context"
    t.index ["tag_id", "taggable_id", "taggable_type", "context", "tagger_id", "tagger_type"], name: "taggings_idx", unique: true
    t.index ["tag_id"], name: "index_taggings_on_tag_id"
    t.index ["taggable_id", "taggable_type", "context"], name: "index_taggings_on_taggable_id_and_taggable_type_and_context"
    t.index ["taggable_id", "taggable_type", "tagger_id", "context"], name: "taggings_idy"
    t.index ["taggable_id"], name: "index_taggings_on_taggable_id"
    t.index ["taggable_type"], name: "index_taggings_on_taggable_type"
    t.index ["tagger_id", "tagger_type"], name: "index_taggings_on_tagger_id_and_tagger_type"
    t.index ["tagger_id"], name: "index_taggings_on_tagger_id"
    t.index ["tenant"], name: "index_taggings_on_tenant"
  end

  create_table "tags", id: :serial, force: :cascade do |t|
    t.string "name"
    t.bigint "taggings_count", default: 0
    t.index ["name"], name: "index_tags_on_name", unique: true
  end

  create_table "users", force: :cascade do |t|
    t.string "first_name", null: false
    t.string "last_name"
    t.citext "username", null: false
    t.string "email", null: false
    t.bigint "blogs_count", default: 0, null: false
    t.bigint "storages_count", default: 0, null: false
    t.bigint "templates_count", default: 0, null: false
    t.bigint "sign_in_count", default: 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet "current_sign_in_ip"
    t.inet "last_sign_in_ip"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["username"], name: "index_users_on_username", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "blogs", "git_providers"
  add_foreign_key "blogs", "users", column: "owner_id"
  add_foreign_key "editions", "revisions"
  add_foreign_key "editions", "users", column: "publisher_id"
  add_foreign_key "git_providers", "users"
  add_foreign_key "identities", "users"
  add_foreign_key "invites", "blogs"
  add_foreign_key "invites", "users", column: "sender_id"
  add_foreign_key "memberships", "blogs"
  add_foreign_key "memberships", "users"
  add_foreign_key "posts", "blogs"
  add_foreign_key "posts", "users", column: "author_id"
  add_foreign_key "revisions", "posts"
  add_foreign_key "revisions", "users", column: "committer_id"
end
