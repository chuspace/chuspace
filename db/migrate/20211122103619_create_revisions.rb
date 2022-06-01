# frozen_string_literal: true

class CreateRevisions < ActiveRecord::Migration[7.0]
  disable_ddl_transaction!

  def change
    create_table :revisions do |t|
      t.references :publication, null: false, foreign_key: true
      t.references :post, null: false, foreign_key: true
      t.references :author, null: false, foreign_key: { to_table: :users }

      t.text :content_before, null: false
      t.text :content_after, null: false

      t.integer :pos_from, null: false
      t.integer :pos_to, null: false
      t.integer :widget_pos, null: false

      t.json :node, null: false

      t.bigint :number, default: 1, null: false

      t.timestamps
    end

    add_column :revisions, :status, "ENUM(#{PublicationConfig.new.revision[:statuses].keys.map { |status| "'#{status}'" }.join(',') }) DEFAULT '#{PublicationConfig.new.revision[:default_status]}'", null: false
    add_index :revisions, %i[publication_id post_id number], unique: true, algorithm: :default
  end
end
