# frozen_string_literal: true

class CreateEditions < ActiveRecord::Migration[7.0]
  disable_ddl_transaction!

  def change
    create_table :editions do |t|
      t.string :permalink, null: false

      t.references :blog, null: false, foreign_key: true
      t.references :publisher, null: false, foreign_key: { to_table: :users }
      t.references :revision, null: false, foreign_key: true

      t.integer  :number, null: false
      t.datetime :published_at, null: false

      t.timestamps
    end

    add_index :editions, %i[revision_id number], unique: true, algorithm: :concurrently
    add_index :editions, %i[blog_id permalink], unique: true, algorithm: :concurrently
    add_index :editions, :published_at, algorithm: :concurrently
  end
end
