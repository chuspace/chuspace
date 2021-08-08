# frozen_string_literal: true

class CreateGitStorageProviderEnumType < ActiveRecord::Migration[6.1]
  def up
    execute <<-SQL
      CREATE TYPE git_storage_provider_enum_type AS ENUM ('github', 'gitlab', 'bitbucket');
    SQL
  end

  def down
    execute <<-SQL
      DROP TYPE git_storage_provider_enum_type AS ENUM ('github', 'gitlab', 'bitbucket');
    SQL
  end
end
