# frozen_string_literal: true

class CreateBlogVisibilityEnumType < ActiveRecord::Migration[6.1]
  def up
    execute <<-SQL
      CREATE TYPE blog_visibility_enum_type AS ENUM ('private', 'public', 'subscriber');
    SQL
  end

  def down
    execute <<-SQL
      DROP TYPE blog_visibility_enum_type;
    SQL
  end
end
