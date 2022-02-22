# frozen_string_literal: true

class AddSearchPgExtensions < ActiveRecord::Migration[7.0]
  def change
    enable_extension('pg_trgm') unless extensions.include?('pg_trgm')
    enable_extension('unaccent') unless extensions.include?('unaccent')
  end
end
