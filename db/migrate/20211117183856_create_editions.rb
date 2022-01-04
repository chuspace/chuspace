# frozen_string_literal: true

class CreateEditions < ActiveRecord::Migration[7.0]
  disable_ddl_transaction!

  def change
    create_table :editions do |t|
      t.references :publisher, null: false, foreign_key: { to_table: :users }
      t.references :revision, null: false, foreign_key: true

      t.bigint :number, null: false
      t.timestamps
    end

    add_index :editions, %i[revision_id number], unique: true, algorithm: :concurrently
  end
end
