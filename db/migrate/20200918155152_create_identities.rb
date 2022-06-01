# frozen_string_literal: true

class CreateIdentities < ActiveRecord::Migration[6.1]
  disable_ddl_transaction!

  def up
    create_table :identities do |t|
      t.string :uid, null: false

      # magic login
      t.string :magic_auth_token, null: false
      t.datetime :magic_auth_token_expires_at

      t.belongs_to :user, null: false, type: :bigint
      t.timestamps
    end

    add_column :identities, :provider, "ENUM('email',#{OmniauthConfig.auth_providers_enum.keys.map { |provider| "'#{provider}'" }.join(',') })", null: false
    add_index :identities, :magic_auth_token, algorithm: :default, unique: true
    add_index :identities, %i[uid provider], unique: true, algorithm: :default
  end

  def down
    drop_table :identities
  end
end
