# frozen_string_literal: true

class CreateMemberships < ActiveRecord::Migration[7.0]
  disable_ddl_transaction!

  def change
    create_table :memberships do |t|
      t.references :publication, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end

    add_column :memberships, :role, "ENUM(#{RolesConfig.to_enum.keys.map { |role| "'#{role}'" }.join(',') }) DEFAULT 'writer'", index: { algorithm: :default }, null: false
  end
end
