# frozen_string_literal: true

class CreateCollaborationSessionMembers < ActiveRecord::Migration[7.0]
  def change
    create_table :collaboration_session_members do |t|
      t.references :collaboration_session, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true

      t.boolean :online, default: false, null: false
      t.boolean :creator, default: false, null: false

      t.datetime :last_seen_at, null: false

      t.timestamps
    end

    add_index :collaboration_session_members, %i[collaboration_session_id user_id], unique: true, name: :one_presence_per_collaboration_session
  end
end