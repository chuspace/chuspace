# frozen_string_literal: true

class CreateRevisions < ActiveRecord::Migration[7.0]
  disable_ddl_transaction!

  def change
    create_table :revisions do |t|
      t.references :blog, null: false, foreign_key: true
      t.references :post, null: false, foreign_key: true
      t.references :author, foreign_key: { to_table: :users }

      t.jsonb :fallback_author, null: false, default: false
      t.jsonb :fallback_committer, null: false, default: false

      t.text :message, null: false
      t.text :content, null: false
      t.text :sha, null: false

      t.integer :number, null: false

      t.timestamps
    end

    add_index :revisions, %i[post_id number], unique: true, algorithm: :concurrently
    add_index :revisions, :sha, algorithm: :concurrently
    add_index :revisions, :number, algorithm: :concurrently
  end
end
