# frozen_string_literal: true

class CreateMemberships < ActiveRecord::Migration[7.0]
  disable_ddl_transaction!

  def change
    create_table :memberships do |t|
      t.belongs_to :publication, null: false, type: :bigint
      t.belongs_to :user, null: false, type: :bigint

      t.timestamps
    end

    add_column :memberships, :role, "ENUM(#{RolesConfig.to_enum.keys.map { |role| "'#{role}'" }.join(',') }) DEFAULT 'writer'", index: { algorithm: :default }, null: false
  end
end
