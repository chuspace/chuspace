# frozen_string_literal: true

class CreatePublishings < ActiveRecord::Migration[7.0]
  disable_ddl_transaction!

  def change
    create_table :publishings do |t|
      t.references :post, null: false, foreign_key: true
      t.references :author, null: false, foreign_key: { to_table: :users }

      t.text :commit_sha, null: false
      t.text :content, null: false

      t.timestamps
    end
  end
end
