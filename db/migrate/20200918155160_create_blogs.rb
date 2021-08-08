# frozen_string_literal: true

class CreateBlogs < ActiveRecord::Migration[6.1]
  def change
    create_table :blogs do |t|
      t.references :user, null: false, foreign_key: true
      t.references :storage, null: false, foreign_key: true
      t.string :git_repo_name, index: { unique: true }

      t.string :framework, null: false
      t.string :posts_folder, null: false
      t.string :drafts_folder, null: false
      t.string :assets_folder, null: false

      t.boolean :default, default: false, null: false, index: true
      t.boolean :public, default: false, null: false, index: true

      t.timestamps
    end
  end
end
