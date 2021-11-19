# frozen_string_literal: true

class CreateRepositories < ActiveRecord::Migration[7.0]
  def change
    create_table :repositories do |t|
      t.string :name
      t.references :blog, null: false, foreign_key: true
      t.string :articles_folder, null: false
      t.string :drafts_folder
      t.string :assets_folder, null: false
      t.string :readme_path, null: false, default: 'README.md'
      t.timestamps
    end
  end
end
