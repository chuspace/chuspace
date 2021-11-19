# frozen_string_literal: true

class CreateIdentities < ActiveRecord::Migration[6.1]
  disable_ddl_transaction!

  def up
    create_table :identities do |t|
      t.text :uid, null: false

      # magic login
      t.string :magic_auth_token, null: false
      t.datetime :magic_auth_token_expires_at

      t.references :user, null: false, foreign_key: true
      t.timestamps
    end

    add_column :identities, :provider, :identity_provider_enum_type, null: false
    add_index :identities, :magic_auth_token, algorithm: :concurrently, unique: true
    add_index :identities, %i[uid provider], unique: true, algorithm: :concurrently
  end

  def down
    drop_table :identities
  end
end
