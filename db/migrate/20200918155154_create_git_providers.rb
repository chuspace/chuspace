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

      t.belongs_to :user, null: false, type: :bigint

      t.json :client_options, null: false

      t.datetime :user_access_token_expires_at
      t.datetime :machine_access_token_expires_at

      t.timestamps
    end

    add_column :git_providers, :name, "ENUM(#{GitStorageConfig.defaults.keys.map { |provider| "'#{provider}'" }.join(',') })", null: false
    add_index :git_providers, %i[app_installation_id name], unique: true, name: :one_installation_per_provider, algorithm: :default
    add_index :git_providers, %i[user_id name], unique: true, name: :one_provider_per_user, algorithm: :default
  end
end
