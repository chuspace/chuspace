# frozen_string_literal: true

# This migration comes from acts_as_taggable_on_engine (originally 1)
if ActiveRecord.gem_version >= Gem::Version.new('5.0')
  class ActsAsTaggableOnMigration < ActiveRecord::Migration[4.2]; end
else
  class ActsAsTaggableOnMigration < ActiveRecord::Migration; end
end
ActsAsTaggableOnMigration.class_eval do
  disable_ddl_transaction!

  def self.up
    create_table :tags do |t|
      t.string :name, null: false
      t.string :display_name
      t.string :created_by
      t.string :released

      t.boolean :featured, index: true, default: false, null: false
      t.boolean :curated, index: true, default: false, null: false

      t.integer :score, default: 0, null: false

      t.text   :short_description
      t.text   :description
    end

    create_table :taggings do |t|
      t.references :tag

      # You should make sure that the column created is
      # long enough to store the required class names.
      t.references :taggable, polymorphic: true
      t.references :tagger, polymorphic: true

      # Limit is created to prevent MySQL error on index
      # length for MyISAM table type: http://bit.ly/vgW2Ql
      t.string :context, limit: 128

      t.datetime :created_at
    end

    add_index :taggings, :tag_id, algorithm: :concurrently
    add_index :taggings, [:taggable_id, :taggable_type, :context], algorithm: :concurrently
  end

  def self.down
    drop_table :taggings
    drop_table :tags
  end
end
