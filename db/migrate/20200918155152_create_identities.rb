# frozen_string_literal: true

class CreateIdentities < ActiveRecord::Migration[6.1]
  disable_ddl_transaction!

  def up
    create_table :identities do |t|
      t.text :uid_ciphertext, null: false
      t.text :uid_bidx, null: false
      t.references :user, null: false, foreign_key: true
      t.timestamps
    end

    add_column :identities, :provider, :identity_provider_enum_type, null: false
    add_index :identities, %i[uid_bidx provider], unique: true, algorithm: :concurrently
  end

  def down
    drop_table :identities
  end
end
