# frozen_string_literal: true

class CreateBlogs < ActiveRecord::Migration[6.1]
  disable_ddl_transaction!

  def change
    create_table :blogs do |t|
      t.string :name, null: false
      t.text :description
      t.string :slug

      t.references :user, null: false, foreign_key: true
      t.references :storage, null: false, foreign_key: true
      t.boolean :default, default: false, null: false

      # Repository info
      t.string :repo_id, null: false
      t.string :repo_fullname, null: false
      t.string :repo_name, null: false
      t.string :repo_owner, null: false
      t.string :repo_ssh_url, null: false
      t.string :repo_html_url, null: false
      t.string :repo_default_branch, null: false, default: :main
      t.string :repo_articles_path, null: false
      t.string :repo_drafts_path, null: false
      t.string :repo_assets_path, null: false
      t.string :repo_about_path

      t.timestamps
    end

    add_index :blogs, :default, algorithm: :concurrently
    add_index :blogs, :slug, algorithm: :concurrently, unique: true
    add_column :blogs, :framework, :blog_framework_enum_type, index: true, null: false, default: BlogFrameworkConfig.default[:framework]
    add_column :blogs, :visibility, :blog_visibility_enum_type, index: true, null: false, default: :private
  end
end
