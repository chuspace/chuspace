# frozen_string_literal: true

class EnableExtensions < ActiveRecord::Migration[6.0]
  disable_ddl_transaction!

  def change
    enable_extension 'citext'
    enable_extension 'hstore'
  end
end
