# frozen_string_literal: true

class DropPublishedAttributeForPosts < ActiveRecord::Migration[7.0]
  def change
    Publication.find_each do |publication|
      publication.front_matter = publication.front_matter.attributes.except('published')
      publication.front_matter.keys = publication.front_matter.attributes.keys - ['published']
      publication.save
    end
  end
end
