# frozen_string_literal: true

class CreateUsers < ActiveRecord::Migration[6.0]
  def change
    enable_extension 'citext'

    create_table :users do |t|
      t.string :name
      t.citext :username, index: { unique: true }
      t.string :email, index: { unique: true }
      t.string :uid, index: true
      t.string :provider, index: true
      t.text :token

      # Git repository settings
      t.string :git_repository_fullname, index: { unique: true }
      t.string :git_repository_posts_folder
      t.string :git_repository_drafts_folder
      t.string :git_repository_assets_folder

      t.index %i[uid provider], unique: true

      t.integer :sign_in_count, default: 0, null: false
      t.datetime :current_sign_in_at, null: false
      t.datetime :last_sign_in_at, null: false
      t.inet :current_sign_in_ip, null: false
      t.inet :last_sign_in_ip, null: false

      t.timestamps null: false
    end
  end
end
