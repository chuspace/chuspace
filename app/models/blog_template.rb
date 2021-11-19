# frozen_string_literal: true

class BlogTemplate < ApplicationRecord
  belongs_to :author, class_name: 'User'
  belongs_to :storage

  extend FriendlyId
  friendly_id :name, use: :history, slug_column: :permalink


  def repository_attributes
    slice(:articles_folder, :drafts_folder, :assets_folder)
  end

  private

  def should_generate_new_friendly_id?
    permalink.blank? || name_changed?
  end

  def resolve_friendly_id_conflict(candidates)
    self.permalink = normalize_friendly_id(name)
  end
end
