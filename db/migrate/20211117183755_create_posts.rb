# frozen_string_literal: true

class CreatePosts < ActiveRecord::Migration[7.0]
  disable_ddl_transaction!

  def change
    create_table :posts do |t|
      t.citext :permalink, null: false

      t.text :title, null: false
      t.text :summary
      t.text :body, null: false
      t.text :body_html, null: false
      t.text :blob_path, null: false
      t.text :blob_sha, null: false
      t.text :commit_sha, null: false
      t.text :canonical_url

      t.integer :version, null: false, default: 1

      t.references :publication, null: false, foreign_key: true
      t.references :author, foreign_key: { to_table: :users }, null: false

      t.boolean :published, null: false, default: true
      t.datetime :date, null: false, index: true

      # Votes
      t.integer :cached_votes_total, default: 0
      t.integer :cached_votes_score, default: 0
      t.integer :cached_votes_up, default: 0
      t.integer :cached_votes_down, default: 0
      t.integer :cached_weighted_score, default: 0
      t.integer :cached_weighted_total, default: 0

      t.float :cached_weighted_average, default: 0.0

      t.timestamps
    end

    add_index :posts, %i[publication_id blob_path version], unique: true, algorithm: :concurrently
    add_index :posts, %i[publication_id permalink], unique: true, algorithm: :concurrently

    add_index :posts, :blob_path, algorithm: :concurrently
    add_index :posts, :permalink, algorithm: :concurrently

    add_column :posts, :visibility, :post_visibility_enum_type, index: { algorithm: :concurrently }, default: :public
  end
end
