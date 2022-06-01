# frozen_string_literal: true

class CreateImages < ActiveRecord::Migration[7.0]
  disable_ddl_transaction!

  def change
    create_table :images do |t|
      t.string :name
      t.string :blob_path
      t.string :draft_blob_path

      t.boolean :featured, default: false

      t.belongs_to :publication, null: false, type: :bigint

      t.timestamps
    end

    add_index :images, %i[publication_id blob_path], unique: true, algorithm: :default
    add_index :images, :name, algorithm: :default
    add_index :images, :blob_path, algorithm: :default
    add_index :images, :draft_blob_path, algorithm: :default
    add_index :images, :featured, algorithm: :default
  end
end
