# frozen_string_literal: true

class CreatePublicationVisibilityEnumType < ActiveRecord::Migration[6.1]
  def up
    execute <<-SQL
      CREATE TYPE publication_visibility_enum_type AS ENUM (#{PublicationConfig.new.visibility.keys.map { |visibility| "'#{visibility}'" }.join(',') });
    SQL
  end

  def down
    execute <<-SQL
      DROP TYPE publication_visibility_enum_type;
    SQL
  end
end
