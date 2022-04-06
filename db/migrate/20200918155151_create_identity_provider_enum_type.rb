# frozen_string_literal: true

class CreateIdentityProviderEnumType < ActiveRecord::Migration[6.1]
  def up
    execute <<-SQL
      CREATE TYPE identity_provider_enum_type AS ENUM ('email',#{OmniauthConfig.auth_providers_enum.keys.map { |provider| "'#{provider}'" }.join(',') });
    SQL
  end

  def down
    execute <<-SQL
      DROP TYPE identity_provider_enum_type;
    SQL
  end
end
