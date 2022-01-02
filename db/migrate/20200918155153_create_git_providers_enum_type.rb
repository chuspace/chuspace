# frozen_string_literal: true

class CreateGitProvidersEnumType < ActiveRecord::Migration[7.0]
  def up
    execute <<-SQL
      CREATE TYPE git_provider_enum_type AS ENUM ('github', 'gitlab');
    SQL
  end

  def down
    execute <<-SQL
      DROP TYPE git_provider_enum_type;
    SQL
  end
end
