# frozen_string_literal: true

class CreateBlogs < ActiveRecord::Migration[6.1]
  disable_ddl_transaction!

  def change
    create_table :blogs do |t|
      t.string :name, null: false
      t.text :description
      t.string :permalink

      t.references :user, null: false, foreign_key: true
      t.references :storage, null: false, foreign_key: true
      t.references :template, foreign_key: true
      t.boolean :default, default: false, null: false
      t.string :repo_fullname, null: false
      t.string :repo_articles_path, null: false
      t.string :repo_drafts_path, null: false
      t.string :readme_path, null: false, default: 'README.md'

      t.timestamps
    end

    add_index :blogs, :default, algorithm: :concurrently
    add_index :blogs, :permalink, algorithm: :concurrently, unique: true
    add_column :blogs, :visibility, :blog_visibility_enum_type, index: true, null: false, default: :private
  end
end
