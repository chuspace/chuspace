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

ActiveRecord::Schema[7.0].define(version: 2022_03_19_171146) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "citext"
  enable_extension "hstore"
  enable_extension "pg_trgm"
  enable_extension "pgcrypto"
  enable_extension "plpgsql"
  enable_extension "unaccent"

  # Custom types defined in this database.
  # Note that some types may not work with other database engines. Be careful if changing database.
  create_enum "git_provider_enum_type", ["github", "gitlab", "gitea"]
  create_enum "identity_provider_enum_type", ["email", "github", "gitlab", "bitbucket"]
  create_enum "invite_status_enum_type", ["pending", "expired", "joined"]
  create_enum "membership_role_enum_type", ["writer", "editor", "admin", "owner", "member"]
  create_enum "post_visibility_enum_type", ["private", "public", "subscriber"]
  create_enum "publication_visibility_enum_type", ["private", "public", "member"]

  create_table "action_text_rich_texts", force: :cascade do |t|
    t.string "name", null: false
    t.text "body"
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["record_type", "record_id", "name"], name: "index_action_text_rich_texts_uniqueness", unique: true
  end

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
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
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "ahoy_events", force: :cascade do |t|
    t.bigint "visit_id"
    t.bigint "user_id"
    t.string "name"
    t.jsonb "properties"
    t.datetime "time"
    t.index ["name", "time"], name: "index_ahoy_events_on_name_and_time"
    t.index ["properties"], name: "index_ahoy_events_on_properties", opclass: :jsonb_path_ops, using: :gin
    t.index ["user_id"], name: "index_ahoy_events_on_user_id"
    t.index ["visit_id"], name: "index_ahoy_events_on_visit_id"
  end

  create_table "ahoy_visits", force: :cascade do |t|
    t.string "visit_token"
    t.string "visitor_token"
    t.bigint "user_id"
    t.string "ip"
    t.text "user_agent"
    t.text "referrer"
    t.string "referring_domain"
    t.text "landing_page"
    t.string "browser"
    t.string "os"
    t.string "device_type"
    t.string "country"
    t.string "region"
    t.string "city"
    t.float "latitude"
    t.float "longitude"
    t.string "utm_source"
    t.string "utm_medium"
    t.string "utm_term"
    t.string "utm_content"
    t.string "utm_campaign"
    t.string "app_version"
    t.string "os_version"
    t.string "platform"
    t.datetime "started_at"
    t.index ["user_id"], name: "index_ahoy_visits_on_user_id"
    t.index ["visit_token"], name: "index_ahoy_visits_on_visit_token", unique: true
  end

  create_table "collaboration_session_members", force: :cascade do |t|
    t.bigint "collaboration_session_id", null: false
    t.bigint "user_id", null: false
    t.boolean "online", default: false, null: false
    t.boolean "creator", default: false, null: false
    t.datetime "last_seen_at", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["collaboration_session_id", "user_id"], name: "one_presence_per_collaboration_session", unique: true
    t.index ["collaboration_session_id"], name: "index_collaboration_session_members_on_collaboration_session_id"
    t.index ["creator"], name: "index_collaboration_session_members_on_creator"
    t.index ["last_seen_at"], name: "index_collaboration_session_members_on_last_seen_at"
    t.index ["online"], name: "index_collaboration_session_members_on_online"
    t.index ["user_id"], name: "index_collaboration_session_members_on_user_id"
  end

  create_table "collaboration_sessions", force: :cascade do |t|
    t.bigint "publication_id", null: false
    t.string "blob_path", null: false
    t.string "initial_ydoc", null: false
    t.string "current_ydoc"
    t.boolean "active", default: true
    t.boolean "doc_changed", default: false
    t.bigint "number", default: 1, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["blob_path"], name: "index_collaboration_sessions_on_blob_path"
    t.index ["publication_id", "blob_path", "number"], name: "one_active_collaboration_session_per_draft", unique: true
    t.index ["publication_id"], name: "index_collaboration_sessions_on_publication_id"
  end

  create_table "friendly_id_slugs", force: :cascade do |t|
    t.citext "slug", null: false
    t.bigint "sluggable_id", null: false
    t.string "sluggable_type", limit: 50
    t.string "scope"
    t.datetime "created_at"
    t.index ["slug", "sluggable_type", "scope"], name: "index_friendly_id_slugs_on_slug_and_sluggable_type_and_scope", unique: true
    t.index ["slug", "sluggable_type"], name: "index_friendly_id_slugs_on_slug_and_sluggable_type"
    t.index ["sluggable_type", "sluggable_id"], name: "index_friendly_id_slugs_on_sluggable_type_and_sluggable_id"
  end

  create_table "git_providers", force: :cascade do |t|
    t.string "label", null: false
    t.text "access_token"
    t.text "refresh_access_token"
    t.text "client_id", null: false
    t.text "client_secret", null: false
    t.text "api_endpoint", null: false
    t.text "refresh_access_token_endpoint", null: false
    t.string "access_token_param", null: false
    t.string "scopes", null: false
    t.bigint "user_id", null: false
    t.datetime "access_token_expires_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.enum "name", null: false, enum_type: "git_provider_enum_type"
    t.index ["user_id", "name"], name: "one_provider_per_user_index", unique: true
    t.index ["user_id"], name: "index_git_providers_on_user_id"
  end

  create_table "good_job_processes", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.jsonb "state"
  end

  create_table "good_jobs", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.text "queue_name"
    t.bigint "priority"
    t.jsonb "serialized_params"
    t.datetime "scheduled_at", precision: nil
    t.datetime "performed_at", precision: nil
    t.datetime "finished_at", precision: nil
    t.text "error"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.uuid "active_job_id"
    t.text "concurrency_key"
    t.text "cron_key"
    t.uuid "retried_good_job_id"
    t.datetime "cron_at", precision: nil
    t.index ["active_job_id", "created_at"], name: "index_good_jobs_on_active_job_id_and_created_at"
    t.index ["active_job_id"], name: "index_good_jobs_on_active_job_id"
    t.index ["concurrency_key"], name: "index_good_jobs_on_concurrency_key_when_unfinished", where: "(finished_at IS NULL)"
    t.index ["cron_key", "created_at"], name: "index_good_jobs_on_cron_key_and_created_at"
    t.index ["cron_key", "cron_at"], name: "index_good_jobs_on_cron_key_and_cron_at", unique: true
    t.index ["finished_at"], name: "index_good_jobs_jobs_on_finished_at", where: "((retried_good_job_id IS NULL) AND (finished_at IS NOT NULL))"
    t.index ["queue_name", "scheduled_at"], name: "index_good_jobs_on_queue_name_and_scheduled_at", where: "(finished_at IS NULL)"
    t.index ["scheduled_at"], name: "index_good_jobs_on_scheduled_at", where: "(finished_at IS NULL)"
  end

  create_table "identities", force: :cascade do |t|
    t.text "uid", null: false
    t.string "magic_auth_token", null: false
    t.datetime "magic_auth_token_expires_at", precision: nil
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.enum "provider", null: false, enum_type: "identity_provider_enum_type"
    t.index ["magic_auth_token"], name: "index_identities_on_magic_auth_token", unique: true
    t.index ["uid", "provider"], name: "index_identities_on_uid_and_provider", unique: true
    t.index ["user_id"], name: "index_identities_on_user_id"
  end

  create_table "invites", force: :cascade do |t|
    t.bigint "sender_id", null: false
    t.bigint "publication_id", null: false
    t.citext "identifier", null: false
    t.text "code"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.enum "role", default: "writer", null: false, enum_type: "membership_role_enum_type"
    t.enum "status", default: "pending", null: false, enum_type: "invite_status_enum_type"
    t.index ["code"], name: "index_invites_on_code", unique: true
    t.index ["identifier", "publication_id"], name: "index_invites_on_identifier_and_publication_id", unique: true
    t.index ["identifier"], name: "index_invites_on_identifier"
    t.index ["publication_id"], name: "index_invites_on_publication_id"
    t.index ["role"], name: "index_invites_on_role"
    t.index ["sender_id"], name: "index_invites_on_sender_id"
    t.index ["status"], name: "index_invites_on_status"
  end

  create_table "memberships", force: :cascade do |t|
    t.bigint "publication_id", null: false
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.enum "role", default: "writer", null: false, enum_type: "membership_role_enum_type"
    t.index ["publication_id"], name: "index_memberships_on_publication_id"
    t.index ["user_id"], name: "index_memberships_on_user_id"
  end

  create_table "pg_search_documents", force: :cascade do |t|
    t.text "content"
    t.string "searchable_type"
    t.bigint "searchable_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["searchable_type", "searchable_id"], name: "index_pg_search_documents_on_searchable"
  end

  create_table "posts", force: :cascade do |t|
    t.citext "permalink", null: false
    t.text "title", null: false
    t.text "summary"
    t.text "body", null: false
    t.text "body_html", null: false
    t.text "blob_path", null: false
    t.text "blob_sha", null: false
    t.text "commit_sha", null: false
    t.text "canonical_url"
    t.integer "version", default: 1, null: false
    t.bigint "publication_id", null: false
    t.bigint "author_id", null: false
    t.jsonb "original_author", default: {}, null: false
    t.boolean "published", default: true, null: false
    t.datetime "date", null: false
    t.integer "cached_votes_total", default: 0
    t.integer "cached_votes_score", default: 0
    t.integer "cached_votes_up", default: 0
    t.integer "cached_votes_down", default: 0
    t.integer "cached_weighted_score", default: 0
    t.integer "cached_weighted_total", default: 0
    t.float "cached_weighted_average", default: 0.0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.enum "visibility", default: "public", enum_type: "post_visibility_enum_type"
    t.index ["author_id"], name: "index_posts_on_author_id"
    t.index ["blob_path"], name: "index_posts_on_blob_path"
    t.index ["date"], name: "index_posts_on_date"
    t.index ["permalink"], name: "index_posts_on_permalink"
    t.index ["publication_id", "blob_path", "version"], name: "index_posts_on_publication_id_and_blob_path_and_version", unique: true
    t.index ["publication_id", "permalink"], name: "index_posts_on_publication_id_and_permalink", unique: true
    t.index ["publication_id"], name: "index_posts_on_publication_id"
  end

  create_table "publications", force: :cascade do |t|
    t.string "name", null: false
    t.citext "permalink", null: false
    t.text "description"
    t.bigint "owner_id", null: false
    t.bigint "git_provider_id", null: false
    t.boolean "personal", default: false, null: false
    t.jsonb "settings", default: {}, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.enum "visibility", default: "private", null: false, enum_type: "publication_visibility_enum_type"
    t.index ["git_provider_id"], name: "index_publications_on_git_provider_id"
    t.index ["owner_id"], name: "index_publications_on_owner_id"
    t.index ["permalink", "owner_id"], name: "index_publications_on_permalink_and_owner_id", unique: true
    t.index ["personal"], name: "index_publications_on_personal"
  end

  create_table "repositories", force: :cascade do |t|
    t.string "full_name", null: false
    t.string "default_ref", default: "HEAD", null: false
    t.bigint "publication_id", null: false
    t.bigint "git_provider_id", null: false
    t.string "webhook_id"
    t.string "posts_folder", null: false
    t.string "drafts_folder"
    t.string "assets_folder", null: false
    t.string "readme_path", default: "README.md"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["full_name"], name: "index_repositories_on_full_name", unique: true
    t.index ["git_provider_id"], name: "index_repositories_on_git_provider_id"
    t.index ["publication_id"], name: "index_repositories_on_publication_id"
  end

  create_table "taggings", id: :serial, force: :cascade do |t|
    t.integer "tag_id"
    t.string "taggable_type"
    t.integer "taggable_id"
    t.string "tagger_type"
    t.integer "tagger_id"
    t.string "context", limit: 128
    t.datetime "created_at", precision: nil
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
    t.citext "email", null: false
    t.bigint "publications_count", default: 0, null: false
    t.bigint "sign_in_count", default: 0
    t.datetime "current_sign_in_at", precision: nil
    t.datetime "last_sign_in_at", precision: nil
    t.inet "current_sign_in_ip"
    t.inet "last_sign_in_ip"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["username"], name: "index_users_on_username", unique: true
  end

  create_table "votes", force: :cascade do |t|
    t.string "votable_type"
    t.bigint "votable_id"
    t.string "voter_type"
    t.bigint "voter_id"
    t.boolean "vote_flag"
    t.string "vote_scope"
    t.integer "vote_weight"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["votable_id", "votable_type", "vote_scope"], name: "index_votes_on_votable_id_and_votable_type_and_vote_scope"
    t.index ["votable_type", "votable_id"], name: "index_votes_on_votable"
    t.index ["voter_id", "voter_type", "vote_scope"], name: "index_votes_on_voter_id_and_voter_type_and_vote_scope"
    t.index ["voter_type", "voter_id"], name: "index_votes_on_voter"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "collaboration_session_members", "collaboration_sessions"
  add_foreign_key "collaboration_session_members", "users"
  add_foreign_key "collaboration_sessions", "publications"
  add_foreign_key "git_providers", "users"
  add_foreign_key "identities", "users"
  add_foreign_key "invites", "publications"
  add_foreign_key "invites", "users", column: "sender_id"
  add_foreign_key "memberships", "publications"
  add_foreign_key "memberships", "users"
  add_foreign_key "posts", "publications"
  add_foreign_key "posts", "users", column: "author_id"
  add_foreign_key "publications", "git_providers"
  add_foreign_key "publications", "users", column: "owner_id"
  add_foreign_key "repositories", "git_providers"
  add_foreign_key "repositories", "publications"
end
