# frozen_string_literal: true

# This migration comes from acts_as_taggable_on_engine (originally 2)
if ActiveRecord.gem_version >= Gem::Version.new('5.0')
  class AddMissingUniqueIndices < ActiveRecord::Migration[4.2]; end
else
  class AddMissingUniqueIndices < ActiveRecord::Migration; end
end
AddMissingUniqueIndices.class_eval do
  disable_ddl_transaction!

  def self.up
    add_index :tags, :name, unique: true, algorithm: :default

    remove_index :taggings, :tag_id if index_exists?(:taggings, :tag_id)
    remove_index :taggings, [:taggable_id, :taggable_type, :context]
    add_index :taggings,
              [:tag_id, :taggable_id, :taggable_type, :context, :tagger_id, :tagger_type],
              unique: true, name: 'taggings_idx', algorithm: :default
  end

  def self.down
    remove_index :tags, :name

    remove_index :taggings, name: 'taggings_idx'

    add_index :taggings, :tag_id unless index_exists?(:taggings, :tag_id)
    add_index :taggings, [:taggable_id, :taggable_type, :context]
  end
end
