# frozen_string_literal: true

class CreateKvs < ActiveRecord::Migration[7.0]
  disable_ddl_transaction!

  def change
    create_table :kvs do |t|
      t.string :key, null: false
      t.text :value
      t.text :default
      t.text :data_type, null: false, default: :string

      t.datetime :expires_in
    end

    add_index :kvs, :key, unique: true, algorithm: :concurrently
    add_index :kvs, :expires_in, algorithm: :concurrently
  end
end
