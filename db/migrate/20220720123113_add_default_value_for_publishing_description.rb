# frozen_string_literal: true

class AddDefaultValueForPublishingDescription < ActiveRecord::Migration[7.0]
  def change
    change_column :publishings, :description, :string, default: 'Published a new version'
  end
end
