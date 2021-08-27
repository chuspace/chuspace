# frozen_string_literal: true

class CreateBlogFrameworkEnumType < ActiveRecord::Migration[6.1]
  def up
    execute <<-SQL
      CREATE TYPE blog_framework_enum_type AS ENUM ('astro', 'bridgetown', 'gatsby', 'jekyll', 'hugo', 'eleventy', 'hexo','publish', 'nextjs', 'nuxtjs', 'gridsome', 'sculpin', 'pelican');
    SQL
  end

  def down
    execute <<-SQL
      DROP TYPE blog_framework_enum_type AS ENUM ('astro', 'bridgetown', 'gatsby', 'jekyll', 'hugo', 'eleventy', 'hexo','publish', 'nextjs', 'nuxtjs', 'gridsome', 'sculpin', 'pelican');
    SQL
  end
end
