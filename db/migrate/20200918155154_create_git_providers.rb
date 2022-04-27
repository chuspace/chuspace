# frozen_string_literal: true

class CreateGitProviders < ActiveRecord::Migration[7.0]
  disable_ddl_transaction!

  def change
    create_table :git_providers do |t|
      t.string :label, null: false

      t.text :machine_access_token
      t.text :user_access_token
      t.text :client_id
      t.text :client_secret
      t.text :api_endpoint

      t.bigint :app_installation_id, index: true

      t.string :user_access_token_param, null: false
      t.string :scopes, null: false

      t.boolean :enabled, null: false, default: true
      t.boolean :self_managed, null: false, default: false

      t.references :user, null: false, foreign_key: true

      t.jsonb :client_options, default: {}, null: false

      t.datetime :user_access_token_expires_at
      t.datetime :machine_access_token_expires_at

      t.timestamps
    end

    add_column :git_providers, :name, :git_provider_enum_type, null: false
    add_index :git_providers, %i[app_installation_id name], unique: true, name: :one_installation_per_provider, algorithm: :concurrently
  end
end
