# frozen_string_literal: true

class CreateContentSourceEnumType < ActiveRecord::Migration[6.1]
  def up
    execute <<-SQL
      CREATE TYPE content_source_enum_type AS ENUM ('chuspace', 'remote');
    SQL
  end

  def down
    execute <<-SQL
      DROP TYPE content_source_enum_type;
    SQL
  end
end
