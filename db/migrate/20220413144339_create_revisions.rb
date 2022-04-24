# frozen_string_literal: true

class CreateRevisions < ActiveRecord::Migration[7.0]
  disable_ddl_transaction!

  def change
    create_enum :revision_status_enum_type, ChuspaceConfig.new.revision[:statuses].keys

    create_table :revisions do |t|
      t.citext :permalink, null: false

      t.references :publication, null: false, foreign_key: true
      t.references :post, null: false, foreign_key: true
      t.references :author, null: false, foreign_key: { to_table: :users }

      t.text :content_before, null: false
      t.text :content_after, null: false

      t.integer :pos_from, null: false
      t.integer :pos_to, null: false
      t.integer :widget_pos, null: false

      t.text :ydoc_base64, null: false
      t.jsonb :node, null: false, default: {}

      t.bigint :number, default: 1, null: false

      t.timestamps
    end

    add_column :revisions, :status, :revision_status_enum_type, null: false, default: ChuspaceConfig.new.revision[:default_status]
    add_index :revisions, %i[publication_id post_id permalink], unique: true, algorithm: :concurrently
  end
end
