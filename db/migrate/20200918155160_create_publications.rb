# frozen_string_literal: true

class CreatePublications < ActiveRecord::Migration[6.1]
  disable_ddl_transaction!

  def change
    create_table :publications do |t|
      t.string :name, null: false
      t.string :permalink, null: false

      t.text :description
      t.string :canonical_url
      t.string :twitter_handle

      t.belongs_to :owner, null: false, type: :bigint
      t.belongs_to :git_provider, null: false, type: :bigint

      t.boolean :personal, default: false, null: false

      t.json :settings, null: false

      t.timestamps
    end

    add_column :publications, :visibility, "ENUM(#{PublicationConfig.new.visibility.keys.map { |visibility| "'#{visibility}'" }.join(',') }) DEFAULT 'public'", index: { algorithm: :default }, null: false

    add_index :publications, :personal, algorithm: :default
    add_index :publications, :visibility, algorithm: :default
    add_index :publications, %i[permalink owner_id], algorithm: :default, unique: true
  end
end
