# frozen_string_literal: true

class CreatePublishings < ActiveRecord::Migration[7.0]
  disable_ddl_transaction!

  def change
    create_table :publishings do |t|
      t.belongs_to :post, null: false, type: :bigint
      t.belongs_to :author, null: false, type: :bigint

      t.string :commit_sha, null: false
      t.text :content, null: false

      t.timestamps
    end
  end
end
