# frozen_string_literal: true

class CreatePublications < ActiveRecord::Migration[6.1]
  disable_ddl_transaction!

  def change
    create_table :publications do |t|
      t.string :name, null: false
      t.citext :permalink, null: false
      t.text :description

      t.references :owner, null: false, foreign_key: { to_table: :users }
      t.references :git_provider, null: false, foreign_key: true

      t.boolean :personal, default: false, null: false

      t.jsonb :settings, null: false, default: {}

      t.timestamps
    end

    add_index :publications, :personal, algorithm: :concurrently
    add_index :publications, %i[permalink owner_id], algorithm: :concurrently, unique: true

    add_column :publications, :visibility, :publication_visibility_enum_type, index: { algorithm: :concurrently }, null: false, default: :private
  end
end
