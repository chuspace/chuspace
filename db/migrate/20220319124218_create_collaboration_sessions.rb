# frozen_string_literal: true

class CreateCollaborationSessions < ActiveRecord::Migration[7.0]
  def change
    create_enum :collaboration_session_state_enum_type, ChuspaceConfig.new.collaboration_session[:states].keys

    create_table :collaboration_sessions do |t|
      t.references :publication, null: false, foreign_key: true

      t.text :path, null: false, index: true
      t.text :initial_ydoc, null: false
      t.text :current_ydoc

      t.boolean :doc_changed, default: false

      t.bigint :number, default: 1, null: false

      t.timestamps
    end

    add_column :collaboration_sessions, :state, :collaboration_session_state_enum_type, null: false, default: :open
    add_index :collaboration_sessions, %i[publication_id blob_path number], unique: true, name: :one_active_collaboration_session_per_draft
  end
end
