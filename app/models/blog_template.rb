# frozen_string_literal: true

class BlogTemplate < ApplicationRecord
  belongs_to :author, class_name: 'User'
  belongs_to :storage

  extend FriendlyId
  friendly_id :name, use: :history, slug_column: :permalink


  def blog_attributes
    {
      repo_articles_folder: articles_folder,
      repo_drafts_folder: drafts_folder,
      repo_assets_folder: assets_folder
    }
  end

  private

  def should_generate_new_friendly_id?
    permalink.blank? || name_changed?
  end

  def resolve_friendly_id_conflict(candidates)
    self.permalink = normalize_friendly_id(name)
  end
end
