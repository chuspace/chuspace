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

ActiveRecord::Schema[7.0].define(version: 2022_10_05_050602) do
  create_table "action_text_rich_texts", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "name", null: false
    t.text "body", size: :long
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["record_type", "record_id", "name"], name: "index_action_text_rich_texts_uniqueness", unique: true
  end

  create_table "active_storage_attachments", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["id"], name: "index_active_storage_attachments_on_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", null: false
    t.index ["id"], name: "index_active_storage_blobs_on_id"
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
    t.index ["id"], name: "index_active_storage_variant_records_on_id"
  end

  create_table "ahoy_events", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "visit_id"
    t.bigint "user_id"
    t.string "name"
    t.json "properties"
    t.datetime "time"
    t.index ["id"], name: "index_ahoy_events_on_id"
    t.index ["name", "time"], name: "index_ahoy_events_on_name_and_time"
    t.index ["user_id"], name: "index_ahoy_events_on_user_id"
    t.index ["visit_id"], name: "index_ahoy_events_on_visit_id"
  end

  create_table "ahoy_visits", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
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
    t.index ["id"], name: "index_ahoy_visits_on_id"
    t.index ["user_id"], name: "index_ahoy_visits_on_user_id"
    t.index ["visit_token"], name: "index_ahoy_visits_on_visit_token", unique: true
  end

  create_table "friendly_id_slugs", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "slug", null: false
    t.bigint "sluggable_id", null: false
    t.string "sluggable_type", limit: 50
    t.string "scope"
    t.datetime "created_at"
    t.index ["id"], name: "index_friendly_id_slugs_on_id"
    t.index ["slug", "sluggable_type", "scope"], name: "index_friendly_id_slugs_on_slug_and_sluggable_type_and_scope", unique: true, length: { slug: 70, scope: 70 }
    t.index ["slug", "sluggable_type"], name: "index_friendly_id_slugs_on_slug_and_sluggable_type", length: { slug: 140 }
    t.index ["sluggable_type", "sluggable_id"], name: "index_friendly_id_slugs_on_sluggable_type_and_sluggable_id"
  end

  create_table "git_providers", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "label", null: false
    t.text "machine_access_token"
    t.text "user_access_token"
    t.text "client_id"
    t.text "client_secret"
    t.text "api_endpoint"
    t.bigint "app_installation_id"
    t.string "user_access_token_param", null: false
    t.string "scopes", null: false
    t.boolean "enabled", default: true, null: false
    t.boolean "self_managed", default: false, null: false
    t.bigint "user_id", null: false
    t.json "client_options", null: false
    t.datetime "user_access_token_expires_at"
    t.datetime "machine_access_token_expires_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.column "name", "enum('github','github_enterprise','gitlab','gitlab_foss','gitea')", null: false
    t.index ["app_installation_id", "name"], name: "one_installation_per_provider", unique: true
    t.index ["app_installation_id"], name: "index_git_providers_on_app_installation_id"
    t.index ["id"], name: "index_git_providers_on_id"
    t.index ["user_id", "name"], name: "one_provider_per_user", unique: true
    t.index ["user_id"], name: "index_git_providers_on_user_id"
  end

  create_table "identities", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "uid", null: false
    t.string "magic_auth_token", null: false
    t.datetime "magic_auth_token_expires_at", precision: nil
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.column "provider", "enum('email','github','gitlab','bitbucket')", null: false
    t.index ["id"], name: "index_identities_on_id"
    t.index ["magic_auth_token"], name: "index_identities_on_magic_auth_token", unique: true
    t.index ["uid", "provider"], name: "index_identities_on_uid_and_provider", unique: true
    t.index ["uid"], name: "index_identities_on_uid"
    t.index ["user_id"], name: "index_identities_on_user_id"
  end

  create_table "images", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "name"
    t.string "blob_path"
    t.string "draft_blob_path"
    t.boolean "featured", default: false
    t.bigint "publication_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["blob_path"], name: "index_images_on_blob_path"
    t.index ["draft_blob_path"], name: "index_images_on_draft_blob_path"
    t.index ["featured"], name: "index_images_on_featured"
    t.index ["id"], name: "index_images_on_id"
    t.index ["name"], name: "index_images_on_name"
    t.index ["publication_id", "blob_path"], name: "index_images_on_publication_id_and_blob_path", unique: true
    t.index ["publication_id"], name: "index_images_on_publication_id"
  end

  create_table "invites", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "sender_id", null: false
    t.bigint "publication_id", null: false
    t.string "identifier", null: false
    t.string "code"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.column "role", "enum('writer','editor','admin','owner')", default: "writer", null: false
    t.column "status", "enum('pending','expired','joined')", default: "pending", null: false
    t.index ["code"], name: "index_invites_on_code", unique: true
    t.index ["id"], name: "index_invites_on_id"
    t.index ["identifier", "publication_id"], name: "index_invites_on_identifier_and_publication_id", unique: true
    t.index ["identifier"], name: "index_invites_on_identifier"
    t.index ["publication_id"], name: "index_invites_on_publication_id"
    t.index ["role"], name: "index_invites_on_role"
    t.index ["sender_id"], name: "index_invites_on_sender_id"
    t.index ["status"], name: "index_invites_on_status"
  end

  create_table "kvs", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "key", null: false
    t.text "value"
    t.text "default"
    t.string "data_type", default: "string", null: false
    t.datetime "expires_in"
    t.index ["expires_in"], name: "index_kvs_on_expires_in"
    t.index ["id"], name: "index_kvs_on_id"
    t.index ["key"], name: "index_kvs_on_key", unique: true
  end

  create_table "memberships", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "publication_id", null: false
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.column "role", "enum('writer','editor','admin','owner')", default: "writer", null: false
    t.index ["id"], name: "index_memberships_on_id"
    t.index ["publication_id", "user_id"], name: "index_memberships_on_publication_id_and_user_id", unique: true
    t.index ["publication_id"], name: "index_memberships_on_publication_id"
    t.index ["user_id"], name: "index_memberships_on_user_id"
  end

  create_table "posts", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "permalink", null: false
    t.text "title", null: false
    t.text "summary"
    t.text "body", null: false
    t.string "blob_path", null: false
    t.string "blob_sha", null: false
    t.string "commit_sha", null: false
    t.string "canonical_url"
    t.bigint "publication_id", null: false
    t.bigint "author_id", null: false
    t.datetime "date", null: false
    t.boolean "unlisted", default: false, null: false
    t.boolean "featured", default: false, null: false
    t.integer "cached_votes_total", default: 0
    t.integer "cached_votes_score", default: 0
    t.integer "cached_votes_up", default: 0
    t.integer "cached_votes_down", default: 0
    t.integer "cached_weighted_score", default: 0
    t.integer "cached_weighted_total", default: 0
    t.float "cached_weighted_average", default: 0.0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.column "visibility", "enum('private','public','member','internal')", default: "public"
    t.bigint "publishings_count", default: 0
    t.index ["author_id"], name: "index_posts_on_author_id"
    t.index ["blob_path"], name: "index_posts_on_blob_path"
    t.index ["date"], name: "index_posts_on_date"
    t.index ["featured"], name: "index_posts_on_featured"
    t.index ["id"], name: "index_posts_on_id"
    t.index ["permalink"], name: "index_posts_on_permalink"
    t.index ["publication_id", "blob_path"], name: "index_posts_on_publication_id_and_blob_path", unique: true
    t.index ["publication_id", "permalink"], name: "index_posts_on_publication_id_and_permalink", unique: true
    t.index ["publication_id", "visibility", "featured"], name: "index_posts_on_publication_id_and_visibility_and_featured"
    t.index ["publication_id", "visibility", "unlisted"], name: "index_posts_on_publication_id_and_visibility_and_unlisted"
    t.index ["publication_id"], name: "index_posts_on_publication_id"
    t.index ["unlisted"], name: "index_posts_on_unlisted"
    t.index ["visibility"], name: "index_posts_on_visibility"
  end

  create_table "publications", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "name", null: false
    t.string "permalink", null: false
    t.text "description"
    t.string "canonical_url"
    t.string "twitter_handle"
    t.bigint "owner_id", null: false
    t.bigint "git_provider_id", null: false
    t.boolean "personal", default: false, null: false
    t.json "settings", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.column "visibility", "enum('private','public','member','internal')", default: "public", null: false
    t.index ["git_provider_id"], name: "index_publications_on_git_provider_id"
    t.index ["id"], name: "index_publications_on_id"
    t.index ["owner_id"], name: "index_publications_on_owner_id"
    t.index ["permalink", "owner_id"], name: "index_publications_on_permalink_and_owner_id", unique: true
    t.index ["permalink"], name: "index_publications_on_permalink"
    t.index ["personal"], name: "index_publications_on_personal"
    t.index ["visibility"], name: "index_publications_on_visibility"
  end

  create_table "publishings", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "post_id", null: false
    t.bigint "author_id", null: false
    t.string "commit_sha", null: false
    t.text "content", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "version", default: 1
    t.boolean "current", default: false
    t.string "description", default: "Published a new version", null: false
    t.index ["author_id"], name: "index_publishings_on_author_id"
    t.index ["id"], name: "index_publishings_on_id"
    t.index ["post_id", "author_id"], name: "index_publishings_on_post_id_and_author_id"
    t.index ["post_id", "version"], name: "index_publishings_on_post_id_and_version", unique: true
    t.index ["post_id"], name: "index_publishings_on_post_id"
  end

  create_table "repositories", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "full_name", null: false
    t.string "default_ref", default: "HEAD", null: false
    t.bigint "publication_id", null: false
    t.bigint "git_provider_id", null: false
    t.string "webhook_id"
    t.string "posts_folder", null: false
    t.string "drafts_folder"
    t.string "assets_folder", null: false
    t.string "readme_path", default: "README.md"
    t.text "readme"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["full_name"], name: "index_repositories_on_full_name", unique: true
    t.index ["git_provider_id"], name: "index_repositories_on_git_provider_id"
    t.index ["id"], name: "index_repositories_on_id"
    t.index ["publication_id"], name: "index_repositories_on_publication_id"
  end

  create_table "revisions", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "publication_id", null: false
    t.bigint "post_id", null: false
    t.bigint "author_id", null: false
    t.text "content_before", null: false
    t.text "content_after", null: false
    t.integer "pos_from", null: false
    t.integer "pos_to", null: false
    t.integer "widget_pos", null: false
    t.json "node", null: false
    t.bigint "number", default: 1, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.column "status", "enum('open','closed','merged')", default: "open", null: false
    t.index ["author_id"], name: "index_revisions_on_author_id"
    t.index ["id"], name: "index_revisions_on_id"
    t.index ["post_id"], name: "index_revisions_on_post_id"
    t.index ["publication_id", "post_id", "number"], name: "index_revisions_on_publication_id_and_post_id_and_number", unique: true
    t.index ["publication_id"], name: "index_revisions_on_publication_id"
  end

  create_table "taggings", id: :integer, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "tag_id"
    t.string "taggable_type"
    t.bigint "taggable_id"
    t.string "tagger_type"
    t.bigint "tagger_id"
    t.string "context", limit: 128
    t.datetime "created_at", precision: nil
    t.string "tenant", limit: 128
    t.index ["context"], name: "index_taggings_on_context"
    t.index ["id"], name: "index_taggings_on_id"
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

  create_table "tags", id: :integer, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "name", collation: "utf8mb3_bin"
    t.string "display_name"
    t.string "created_by"
    t.string "released"
    t.boolean "featured", default: false, null: false
    t.boolean "curated", default: false, null: false
    t.integer "score", default: 0, null: false
    t.text "short_description"
    t.text "description"
    t.bigint "taggings_count", default: 0
    t.index ["curated"], name: "index_tags_on_curated"
    t.index ["featured"], name: "index_tags_on_featured"
    t.index ["id"], name: "index_tags_on_id"
    t.index ["name"], name: "index_tags_on_name", unique: true
  end

  create_table "users", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "first_name", null: false
    t.string "last_name"
    t.string "username", null: false
    t.string "email", null: false
    t.text "readme"
    t.bigint "publications_count", default: 0, null: false
    t.bigint "sign_in_count", default: 0
    t.datetime "current_sign_in_at", precision: nil
    t.datetime "last_sign_in_at", precision: nil
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["id"], name: "index_users_on_id"
    t.index ["username"], name: "index_users_on_username", unique: true
  end

  create_table "votes", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
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

end
