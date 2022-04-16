# frozen_string_literal: true

class CreateRevisions < ActiveRecord::Migration[7.0]
  def change
    create_enum :revision_state_enum_type, ChuspaceConfig.new.revision[:states].keys

    create_table :revisions do |t|
      t.references :publication, null: false, foreign_key: true
      t.references :post, null: false, foreign_key: true
      t.references :author, null: false, foreign_key: { to_table: :users }

      t.text :fragment_before, null: false
      t.text :fragment_after, null: false

      t.integer :pos_from, null: false
      t.integer :pos_to, null: false

      t.bigint :number, default: 1, null: false

      t.timestamps
    end

    add_column :revisions, :state, :revision_state_enum_type, null: false, default: :draft
  end
end
