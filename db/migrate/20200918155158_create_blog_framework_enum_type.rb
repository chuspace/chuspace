# frozen_string_literal: true

class CreateBlogFrameworkEnumType < ActiveRecord::Migration[6.1]
  def up
    execute <<-SQL
      CREATE TYPE blog_framework_enum_type AS ENUM (#{BlogFrameworkConfig.defaults.keys.map { |framework| "'#{framework}'"} .join(',') });
    SQL
  end

  def down
    execute <<-SQL
      DROP TYPE blog_framework_enum_type;
    SQL
  end
end
