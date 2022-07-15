# frozen_string_literal: true

class AddVersionToPublishings < ActiveRecord::Migration[7.0]
  def change
    add_column :publishings, :version, :integer, default: 1
    add_index :publishings, %i[post_id version], unique: true, algorithm: :default
  end
end
