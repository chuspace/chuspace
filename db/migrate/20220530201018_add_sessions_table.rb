# frozen_string_literal: true

class AddSessionsTable < ActiveRecord::Migration[7.0]
  disable_ddl_transaction!

  def change
    create_table :sessions do |t|
      t.string :session_id, null: false
      t.belongs_to :identity, type: :bigint
      t.text :data
      t.timestamps
    end

    add_index :sessions, :session_id, unique: true, algorithm: :default
  end
end
