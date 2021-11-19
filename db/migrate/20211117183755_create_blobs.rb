# frozen_string_literal: true

class CreateBlobs < ActiveRecord::Migration[7.0]
  disable_ddl_transaction!

  def change
    create_table :blobs do |t|
      t.string :name
      t.references :repository, null: false, foreign_key: true
      t.string :path
      t.string :sha

      t.timestamps
    end

    add_index :blobs, %i[repository_id path], unique: true, algorithm: :concurrently
  end
end
