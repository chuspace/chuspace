# frozen_string_literal: true

class CreateBlogs < ActiveRecord::Migration[6.1]
  disable_ddl_transaction!

  def change
    create_table :blogs do |t|
      t.string :name, null: false
      t.string :slug
      t.string :description

      t.references :user, null: false, foreign_key: true
      t.references :storage, null: false, foreign_key: true
      t.jsonb :git_repo, null: false, default: '{}'

      t.string :posts_folder, null: false
      t.string :drafts_folder, null: false
      t.string :assets_folder, null: false

      t.boolean :default, default: false, null: false

      t.timestamps
    end

    add_index :blogs, :default, algorithm: :concurrently
    add_index :blogs, :slug, algorithm: :concurrently, unique: true
    add_index :blogs, :git_repo, using: :gin, algorithm: :concurrently
    add_index :blogs, "(git_repo->'id')", using: :gin, name: :index_blog_git_repo_id, algorithm: :concurrently
    add_index :blogs, "(git_repo->'fullname')", using: :gin, name: :index_blog_git_repo_fullname, algorithm: :concurrently
    add_index :blogs, "(git_repo->'name')", using: :gin, name: :index_blog_git_repo_name, algorithm: :concurrently

    add_column :blogs, :framework, :blog_framework_enum_type, index: true, null: false, default: BlogFrameworkConfig.default[:framework]
    add_column :blogs, :visibility, :blog_visibility_enum_type, index: true, null: false, default: :private
  end
end
