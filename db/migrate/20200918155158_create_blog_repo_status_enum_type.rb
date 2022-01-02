# frozen_string_literal: true

class CreateBlogRepoStatusEnumType < ActiveRecord::Migration[6.1]
  def up
    execute <<-SQL
      CREATE TYPE blog_repo_status_enum_type AS ENUM ('syncing', 'synced', 'failed');
    SQL
  end

  def down
    execute <<-SQL
      DROP TYPE blog_repo_status_enum_type;
    SQL
  end
end
