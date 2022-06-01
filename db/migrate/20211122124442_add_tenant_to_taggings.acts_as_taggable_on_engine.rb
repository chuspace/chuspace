# frozen_string_literal: true

# This migration comes from acts_as_taggable_on_engine (originally 7)
if ActiveRecord.gem_version >= Gem::Version.new('5.0')
  class AddTenantToTaggings < ActiveRecord::Migration[4.2]; end
else
  class AddTenantToTaggings < ActiveRecord::Migration; end
end
AddTenantToTaggings.class_eval do
  disable_ddl_transaction!

  def self.up
    add_column ActsAsTaggableOn.taggings_table, :tenant, :string, limit: 128
    add_index ActsAsTaggableOn.taggings_table, :tenant,
algorithm: :default unless index_exists? ActsAsTaggableOn.taggings_table,
:tenant
  end

  def self.down
    remove_index ActsAsTaggableOn.taggings_table, :tenant
    remove_column ActsAsTaggableOn.taggings_table, :tenant
  end
end
