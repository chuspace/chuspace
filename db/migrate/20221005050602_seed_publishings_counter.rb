# frozen_string_literal: true

class SeedPublishingsCounter < ActiveRecord::Migration[7.0]
  def change
    Post.find_each do |post|
      Post.reset_counters(post.id, :publishings)
    end
  end
end
