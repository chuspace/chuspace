# frozen_string_literal: true

class CreatePosts < ActiveRecord::Migration[7.0]
  disable_ddl_transaction!

  def change
    create_table :posts do |t|
      t.string :permalink, null: false

      t.text :title, null: false
      t.text :summary
      t.text :body, null: false
      t.string :blob_path, null: false
      t.string :blob_sha, null: false
      t.string :commit_sha, null: false
      t.string :canonical_url

      t.belongs_to :publication, null: false, type: :bigint
      t.belongs_to :author, null: false, type: :bigint

      t.datetime :date, null: false, index: true

      t.boolean :unlisted, default: false, null: false
      t.boolean :featured, default: false, null: false

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

    add_index :posts, %i[publication_id blob_path], unique: true, algorithm: :default
    add_index :posts, %i[publication_id permalink], unique: true, algorithm: :default

    add_column :posts, :visibility, "ENUM(#{PublicationConfig.new.visibility.keys.map { |visibility| "'#{visibility}'" }.join(',') }) DEFAULT 'public'", index: { algorithm: :default }

    add_index :posts, :blob_path, algorithm: :default
    add_index :posts, :permalink, algorithm: :default
    add_index :posts, :unlisted, algorithm: :default
    add_index :posts, :featured, algorithm: :default
    add_index :posts, :visibility, algorithm: :default
  end
end
