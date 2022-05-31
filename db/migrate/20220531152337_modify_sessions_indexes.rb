# frozen_string_literal: true

class ModifySessionsIndexes < ActiveRecord::Migration[7.0]
  disable_ddl_transaction!

  def change
    remove_index :sessions, :session_id, unique: true
    remove_index :sessions, :updated_at
    add_index :sessions, :session_id, unique: true, algorithm: :concurrently
  end
end
