# frozen_string_literal: true

class CreateEditingLocks < ActiveRecord::Migration[7.0]
  def change
    create_table :editing_locks do |t|
      t.references :publication, null: false, foreign_key: true
      t.string :blob_path
      t.text :content
      t.references :owner, null: false, foreign_key: { to_table: :users }
      t.datetime :expires_at

      t.timestamps
    end

    add_index :editing_locks, %i[blob_path publication_id], unique: true
  end
end
