# frozen_string_literal: true

class AddFrontmatterAttributesToPosts < ActiveRecord::Migration[7.0]
  disable_ddl_transaction!

  def change
    add_column :posts, :unlisted, :boolean, default: false
    add_column :posts, :featured, :boolean, default: false

    add_index :posts, :unlisted, algorithm: :concurrently
    add_index :posts, :featured, algorithm: :concurrently

    Publication.find_each do |publication|
      publication.update(front_matter: PublicationConfig.new.front_matter)
    end
  end
end
