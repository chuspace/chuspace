# frozen_string_literal: true

class CreateImages < ActiveRecord::Migration[7.0]
  disable_ddl_transaction!

  def change
    create_table :images do |t|
      t.string :name, index: { algorithm: :default }
      t.string :blob_path, index: { algorithm: :default }
      t.string :draft_blob_path, index: { algorithm: :default }

      t.boolean :featured, default: false, index: { algorithm: :default }

      t.references :publication, null: false, foreign_key: true

      t.timestamps
    end

    add_index :images, %i[publication_id blob_path], unique: true, algorithm: :default
  end
end
