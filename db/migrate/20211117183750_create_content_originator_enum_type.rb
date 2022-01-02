# frozen_string_literal: true

class CreateContentOriginatorEnumType < ActiveRecord::Migration[6.1]
  def up
    execute <<-SQL
      CREATE TYPE content_originator_enum_type AS ENUM ('chuspace', 'github', 'gitlab');
    SQL
  end

  def down
    execute <<-SQL
      DROP TYPE content_originator_enum_type;
    SQL
  end
end
