# frozen_string_literal: true

class CreateGitProviders < ActiveRecord::Migration[7.0]
  disable_ddl_transaction!

  def change
    create_table :git_providers do |t|
      t.string :label, null: false

      t.text :access_token
      t.text :refresh_access_token
      t.text :endpoint

      t.references :user, null: false, foreign_key: true

      t.datetime :expires_at

      t.timestamps
    end

    add_column :git_providers, :name, :git_provider_enum_type, null: false

    add_index :git_providers, %i[user_id name], unique: true, name: :one_provider_per_user_index, algorithm: :concurrently
  end
end
