# frozen_string_literal: true

class CreateIdentityProviderEnumType < ActiveRecord::Migration[6.1]
  def up
    execute <<-SQL
      CREATE TYPE identity_provider_enum_type AS ENUM ('github', 'gitlab', 'bitbucket', 'email');
    SQL
  end

  def down
    execute <<-SQL
      DROP TYPE identity_provider_enum_type AS ENUM ('github', 'gitlab', 'bitbucket', 'email');
    SQL
  end
end
