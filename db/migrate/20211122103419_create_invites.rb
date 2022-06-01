# frozen_string_literal: true

class CreateInvites < ActiveRecord::Migration[7.0]
  disable_ddl_transaction!

  def change
    create_table :invites do |t|
      t.belongs_to :sender, null: false, type: :bigint
      t.belongs_to :publication, null: false, type: :bigint
      t.string :identifier, null: false
      t.string :code

      t.timestamps
    end

    add_column :invites, :role, "ENUM(#{RolesConfig.to_enum.keys.map { |role| "'#{role}'" }.join(',') }) DEFAULT 'writer'", null: false
    add_column :invites, :status, "ENUM('pending', 'expired', 'joined') DEFAULT 'pending'", null: false

    add_index :invites, :code, algorithm: :default, unique: true
    add_index :invites, %i[identifier publication_id], unique: true, algorithm: :default
    add_index :invites, :identifier, algorithm: :default
    add_index :invites, :role, algorithm: :default
    add_index :invites, :status, algorithm: :default
  end
end
