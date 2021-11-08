# frozen_string_literal: true

class CreateArticles < ActiveRecord::Migration[7.0]
  disable_ddl_transaction!

  def change
    create_table :articles do |t|
      t.string :title
      t.text :intro
      t.text :content_md
      t.text :content_html
      t.string :permalink, null: false
      t.datetime :published_at
      t.boolean :readme, default: false
      t.string :tags, array: true, default: []
      t.string :blob_path, null: false
      t.references :blog, null: false, foreign_key: true
      t.references :author, null: false, foreign_key: { to_table: :users }
      t.string :blob_sha, null: false

      t.timestamps
    end

    add_column :articles, :visibility, :article_visibility_enum_type, default: 'private'
    add_index :articles, :visibility, algorithm: :concurrently
    add_index :articles, :readme, algorithm: :concurrently
    add_index :articles, :published_at, algorithm: :concurrently
    add_index :articles, :tags, algorithm: :concurrently, using: :gin
    add_index :articles, :blob_path, unique: true, algorithm: :concurrently
    add_index :articles, :blob_sha, algorithm: :concurrently
  end
end
