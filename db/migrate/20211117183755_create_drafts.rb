# frozen_string_literal: true

class CreateDrafts < ActiveRecord::Migration[7.0]
  disable_ddl_transaction!

  def change
    create_table :drafts do |t|
      t.string :blob_path, null: false
      t.references :blog, null: false, foreign_key: true
      t.timestamps
    end

    add_index :drafts, %i[blog_id blob_path], unique: true, algorithm: :concurrently
    add_index :drafts, :blob_path, algorithm: :concurrently
  end
end
