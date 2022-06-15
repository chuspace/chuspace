# frozen_string_literal: true

class AddMissingIndexes < ActiveRecord::Migration[7.0]
  def change
    # Index ids
    add_index :users, :id, algorithm: :default
    add_index :identities, :id, algorithm: :default
    add_index :identities, :uid, algorithm: :default
    add_index :git_providers, :id, algorithm: :default
    add_index :friendly_id_slugs, :id, algorithm: :default
    add_index :publications, :id, algorithm: :default
    add_index :repositories, :id, algorithm: :default
    add_index :images, :id, algorithm: :default
    add_index :memberships, :id, algorithm: :default
    add_index :invites, :id, algorithm: :default
    add_index :revisions, :id, algorithm: :default
    add_index :posts, :id, algorithm: :default
    add_index :tags, :id, algorithm: :default
    add_index :taggings, :id, algorithm: :default
    add_index :publishings, :id, algorithm: :default
    add_index :active_storage_blobs, :id, algorithm: :default
    add_index :active_storage_attachments, :id, algorithm: :default
    add_index :active_storage_variant_records, :id, algorithm: :default
    add_index :ahoy_visits, :id, algorithm: :default
    add_index :ahoy_events, :id, algorithm: :default
    add_index :kvs, :id, algorithm: :default

    #  Index others
    add_index :publications, :permalink, algorithm: :default
    add_index :publishings, %i[post_id author_id], algorithm: :default
    add_index :posts, %i[publication_id visibility unlisted], algorithm: :default
    add_index :posts, %i[publication_id visibility featured], algorithm: :default
  end
end
