# frozen_string_literal: true

class CreateStorages < ActiveRecord::Migration[6.1]
  def change
    create_table :storages do |t|
      t.text :access_token_ciphertext, null: false
      t.references :user, null: false, foreign_key: true
      t.boolean :default, default: false

      t.timestamps
    end

    add_column :storages, :provider, :git_storage_provider_enum_type, index: true, null: false
    add_index :storages, %i[user_id provider], unique: true
  end
end
