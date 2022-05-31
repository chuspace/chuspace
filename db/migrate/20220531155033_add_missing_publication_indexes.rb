# frozen_string_literal: true

class AddMissingPublicationIndexes < ActiveRecord::Migration[7.0]
  disable_ddl_transaction!

  def change
    add_index :publications, :visibility, algorithm: :concurrently
  end
end
