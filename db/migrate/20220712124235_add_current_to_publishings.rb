# frozen_string_literal: true

class AddCurrentToPublishings < ActiveRecord::Migration[7.0]
  def change
    add_column :publishings, :current, :boolean, default: false, index: { algorithm: :default }
  end
end
