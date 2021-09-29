# frozen_string_literal: true

class CreateStorages < ActiveRecord::Migration[6.1]
  disable_ddl_transaction!

  def change
    create_table :storages do |t|
      t.string :description, null: false
      t.text :endpoint
      t.text :access_token, null: false
      t.references :user, null: false, foreign_key: true
      t.boolean :default, default: false
      t.boolean :active, default: false

      t.timestamps
    end

    add_column :storages, :provider, :git_storage_provider_enum_type, null: false
    add_index :storages, %i[user_id provider], unique: true, algorithm: :concurrently
    add_index :storages, :default, algorithm: :concurrently
    add_index :storages, :active, algorithm: :concurrently
  end
end
