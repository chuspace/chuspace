# frozen_string_literal: true

class CreateOnboardingStatusEnumType < ActiveRecord::Migration[6.1]
  def up
    execute <<-SQL
      CREATE TYPE onboarding_status_enum_type AS ENUM ('profile', 'storage', 'blog', 'follow', 'complete');
    SQL
  end

  def down
    execute <<-SQL
      DROP TYPE onboarding_status_enum_type AS ENUM ('profile', 'storage', 'blog', 'follow', 'complete');
    SQL
  end
end
