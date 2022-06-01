# frozen_string_literal: true

class CreateRepositories < ActiveRecord::Migration[7.0]
  def change
    create_table :repositories do |t|
      t.string :full_name, null: false
      t.string :default_ref, default: 'HEAD', null: false

      t.belongs_to :publication, null: false, type: :bigint
      t.belongs_to :git_provider, null: false, type: :bigint

      # Content
      t.string :webhook_id
      t.string :posts_folder, null: false
      t.string :drafts_folder
      t.string :assets_folder, null: false
      t.string :readme_path, default: PublicationConfig.new.repo[:readme_path]

      # Store readme
      t.text :readme

      t.timestamps
    end

    add_index :repositories, :full_name, unique: true
  end
end
