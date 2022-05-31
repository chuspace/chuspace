# frozen_string_literal: true

class AddMissingPostIndexes < ActiveRecord::Migration[7.0]
  disable_ddl_transaction!

  def change
    add_index :posts, :visibility, algorithm: :concurrently
  end
end
