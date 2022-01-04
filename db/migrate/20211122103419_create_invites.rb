# frozen_string_literal: true

class CreateInvites < ActiveRecord::Migration[7.0]
  disable_ddl_transaction!

  def change
    create_table :invites do |t|
      t.references :sender, null: false, foreign_key: { to_table: :users }
      t.references :blog, null: false, foreign_key: true
      t.citext :identifier, null: false
      t.text :code

      t.timestamps
    end

    add_column :invites, :role, :membership_role_enum_type, null: false, default: :writer
    add_column :invites, :status, :invite_status_enum_type, null: false, default: :pending

    add_index :invites, :code, algorithm: :concurrently, unique: true
    add_index :invites, %i[identifier blog_id], unique: true, algorithm: :concurrently
    add_index :invites, :identifier, algorithm: :concurrently
    add_index :invites, :role, algorithm: :concurrently
    add_index :invites, :status, algorithm: :concurrently
  end
end
