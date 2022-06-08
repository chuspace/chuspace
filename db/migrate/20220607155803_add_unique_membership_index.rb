# frozen_string_literal: true

class AddUniqueMembershipIndex < ActiveRecord::Migration[7.0]
  def change
    add_index :memberships, %i[publication_id user_id], unique: true, algorithm: :default
  end
end
