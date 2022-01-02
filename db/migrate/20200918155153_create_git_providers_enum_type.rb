# frozen_string_literal: true

class CreateGitProvidersEnumType < ActiveRecord::Migration[7.0]
  def up
    execute <<-SQL
      CREATE TYPE git_provider_enum_type AS ENUM (#{GitStorageConfig.defaults.keys.map { |provider| "'#{provider}'" } .join(',') });
    SQL
  end

  def down
    execute <<-SQL
      DROP TYPE git_provider_enum_type;
    SQL
  end
end
