# frozen_string_literal: true

class CreateMemberships < ActiveRecord::Migration[7.0]
  disable_ddl_transaction!

  def change
    create_table :memberships do |t|
      t.references :blog, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end

    add_column :memberships, :role, :membership_role_enum_type, index: { algorithm: :concurrently }, null: false, default: :writer
  end
end
