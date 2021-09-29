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

ActiveRecord::Schema.define(version: 2021_07_11_062216) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "citext"
  enable_extension "plpgsql"

# Could not dump table "blogs" because of following StandardError
#   Unknown type 'blog_framework_enum_type' for column 'framework'

  create_table "friendly_id_slugs", force: :cascade do |t|
    t.string "slug", null: false
    t.integer "sluggable_id", null: false
    t.string "sluggable_type", limit: 50
    t.string "scope"
    t.datetime "created_at"
    t.index ["slug", "sluggable_type", "scope"], name: "index_friendly_id_slugs_on_slug_and_sluggable_type_and_scope", unique: true
    t.index ["slug", "sluggable_type"], name: "index_friendly_id_slugs_on_slug_and_sluggable_type"
    t.index ["sluggable_type", "sluggable_id"], name: "index_friendly_id_slugs_on_sluggable_type_and_sluggable_id"
  end

# Could not dump table "identities" because of following StandardError
#   Unknown type 'identity_provider_enum_type' for column 'provider'

# Could not dump table "storages" because of following StandardError
#   Unknown type 'git_storage_provider_enum_type' for column 'provider'

  create_table "users", force: :cascade do |t|
    t.string "name"
    t.citext "username"
    t.string "email_ciphertext", null: false
    t.string "email_bidx", null: false
    t.integer "sign_in_count", default: 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet "current_sign_in_ip"
    t.inet "last_sign_in_ip"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["email_bidx"], name: "index_users_on_email_bidx", unique: true
    t.index ["username"], name: "index_users_on_username", unique: true
  end

  add_foreign_key "blogs", "storages"
  add_foreign_key "blogs", "users"
  add_foreign_key "identities", "users"
  add_foreign_key "storages", "users"
end
