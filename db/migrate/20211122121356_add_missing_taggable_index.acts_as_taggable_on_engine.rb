# frozen_string_literal: true

# This migration comes from acts_as_taggable_on_engine (originally 4)
if ActiveRecord.gem_version >= Gem::Version.new('5.0')
  class AddMissingTaggableIndex < ActiveRecord::Migration[4.2]; end
else
  class AddMissingTaggableIndex < ActiveRecord::Migration; end
end
AddMissingTaggableIndex.class_eval do
  disable_ddl_transaction!

  def self.up
    add_index :taggings, [:taggable_id, :taggable_type, :context], algorithm: :default
  end

  def self.down
    remove_index :taggings, [:taggable_id, :taggable_type, :context]
  end
end
