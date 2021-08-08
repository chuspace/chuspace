# frozen_string_literal: true

class CreateIdentities < ActiveRecord::Migration[6.1]
  def up
    create_table :identities do |t|
      t.text :uid_ciphertext, null: false
      t.text :uid_bidx, null: false

      t.references :user, null: false, foreign_key: true
      t.text :access_token_ciphertext, null: false
      t.text :access_token_secret_ciphertext

      t.timestamp :expires_at
      t.timestamps
    end

    add_column :identities, :provider, :identity_provider_enum_type, index: true, null: false
    add_index :identities, %i[uid_bidx provider], unique: true
  end

  def down
    drop_table :identities
  end
end
