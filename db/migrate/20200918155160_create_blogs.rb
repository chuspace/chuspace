# frozen_string_literal: true

class CreateBlogs < ActiveRecord::Migration[6.1]
  disable_ddl_transaction!

  def change
    create_table :blogs do |t|
      t.string :name, null: false
      t.citext :permalink, null: false
      t.text :description

      t.references :owner, null: false, foreign_key: { to_table: :users }
      t.references :git_provider, null: false, foreign_key: true

      t.boolean :personal, default: false, null: false

      # Repository
      t.string :repo_fullname, null: false
      t.string :repo_posts_dir, null: false
      t.string :repo_drafts_dir
      t.string :repo_assets_dir, null: false
      t.string :repo_readme_path, default: 'README.md'

      # Front matter
      t.text :front_matter_attributes_map, null: false, default: MarkdownConfig.new.front_matter['attributes_map']

      t.datetime :repo_last_synced_at

      t.bigint :repo_webhook_id

      t.timestamps
    end

    add_index :blogs, :personal, algorithm: :concurrently
    add_index :blogs, %i[permalink owner_id], algorithm: :concurrently, unique: true

    add_column :blogs, :visibility, :blog_visibility_enum_type, index: { algorithm: :concurrently }, null: false, default: :private
    add_column :blogs, :repo_status, :blog_repo_status_enum_type, index: { algorithm: :concurrently }, null: false, default: :syncing
  end
end
