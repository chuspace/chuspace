# frozen_string_literal: true

class CreateRevisions < ActiveRecord::Migration[7.0]
  disable_ddl_transaction!

  def change
    create_table :revisions do |t|
      t.references :post, null: false, foreign_key: true
      t.references :committer, foreign_key: { to_table: :users }
      t.jsonb :fallback_committer, null: false, default: {}

      t.text :message, null: false, default: ''
      t.text :content, null: false, default: ''
      t.text :sha, null: false

      t.bigint :number, null: false

      t.timestamps
    end

    add_index :revisions, %i[post_id number], unique: true, algorithm: :concurrently
    add_index :revisions, :sha, algorithm: :concurrently
    add_index :revisions, :number, algorithm: :concurrently

    add_column :revisions, :originator, :content_originator_enum_type, index: { algorithm: :concurrently }, null: false, default: :chuspace
  end
end
