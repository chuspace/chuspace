# frozen_string_literal: true

class CreateArticleVisibilityEnumType < ActiveRecord::Migration[6.1]
  def up
    execute <<-SQL
      CREATE TYPE article_visibility_enum_type AS ENUM ('private', 'public', 'internal');
    SQL
  end

  def down
    execute <<-SQL
      DROP TYPE article_visibility_enum_type;
    SQL
  end
end
