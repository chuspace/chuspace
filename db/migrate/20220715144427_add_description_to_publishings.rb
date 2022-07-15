# frozen_string_literal: true

class AddDescriptionToPublishings < ActiveRecord::Migration[7.0]
  def change
    add_column :publishings, :description, :string, null: false
  end
end
