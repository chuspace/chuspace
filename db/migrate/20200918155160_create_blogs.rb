# frozen_string_literal: true

class CreateBlogs < ActiveRecord::Migration[6.1]
  def change
    create_table :blogs do |t|
      t.string :name, null: false
      t.string :slug, index: { unique: true }
      t.string :description

      t.references :user, null: false, foreign_key: true
      t.references :storage, null: false, foreign_key: true
      t.integer :git_repo_id, index: { unique: true }, null: false

      t.string :posts_folder, null: false
      t.string :drafts_folder, null: false
      t.string :assets_folder, null: false

      t.boolean :default, default: false, null: false, index: true

      t.timestamps
    end

    add_column :blogs, :framework, :blog_framework_enum_type, index: true, null: false, default: BlogFrameworkConfig.default[:framework]
    add_column :blogs, :visibility, :blog_visibility_enum_type, index: true, null: false, default: :private
  end
end
