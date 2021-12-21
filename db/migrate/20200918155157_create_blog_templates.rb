# frozen_string_literal: true

class CreateBlogTemplates < ActiveRecord::Migration[7.0]
  disable_ddl_transaction!

  def change
    create_table :blog_templates do |t|
      t.string :name, null: false
      t.string :description
      t.string :permalink, null: false
      t.string :language, null: false
      t.string :framework, null: false
      t.string :css

      t.references :author, foreign_key: { to_table: :users }

      t.string :chuspace_mirror_path
      t.string :preview_url
      t.string :repo_url, null: false
      t.string :repo_posts_folder, null: false
      t.string :repo_drafts_folder
      t.string :repo_assets_folder, null: false
      t.string :repo_readme_path, null: false, default: 'README.md'

      t.boolean :default, null: false, default: false
      t.boolean :approved, null: false, default: false
      t.boolean :system, null: false, default: false

      t.bigint :downloads_count, null: false, default: 0

      t.timestamps
    end

    add_column :blog_templates, :visibility, :template_visibility_enum_type, default: :public
    add_index :blog_templates, :default, algorithm: :concurrently
    add_index :blog_templates, :approved, algorithm: :concurrently
    add_index :blog_templates, :system, algorithm: :concurrently
    add_index :blog_templates, :visibility, algorithm: :concurrently
    add_index :blog_templates, :framework, algorithm: :concurrently
    add_index :blog_templates, :css, algorithm: :concurrently
    add_index :blog_templates, :language, algorithm: :concurrently
    add_index :blog_templates, :permalink, unique: true, algorithm: :concurrently
  end
end
