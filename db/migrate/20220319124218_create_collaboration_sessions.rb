# frozen_string_literal: true

class CreateCollaborationSessions < ActiveRecord::Migration[7.0]
  def change
    create_table :collaboration_sessions do |t|
      t.references :publication, null: false, foreign_key: true

      t.string :blob_path, null: false, index: true
      t.string :initial_ydoc, null: false
      t.string :current_ydoc

      t.boolean :active, default: true
      t.boolean :doc_changed, default: false
      t.boolean :stale, default: false

      t.bigint :number, default: 1, null: false

      t.timestamps
    end

    add_index :collaboration_sessions, %i[publication_id blob_path number], unique: true, name: :one_active_collaboration_session_per_draft
  end
end
