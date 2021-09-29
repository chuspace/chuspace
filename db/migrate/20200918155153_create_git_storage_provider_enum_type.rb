# frozen_string_literal: true

class CreateGitStorageProviderEnumType < ActiveRecord::Migration[6.1]
  def up
    execute <<-SQL
      CREATE TYPE git_storage_provider_enum_type AS ENUM (#{GitStorageConfig.defaults.keys.map { |provider| "'#{provider}'"} .join(',') });
    SQL
  end

  def down
    execute <<-SQL
      DROP TYPE git_storage_provider_enum_type;
    SQL
  end
end
