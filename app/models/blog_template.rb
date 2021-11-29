# frozen_string_literal: true

class BlogTemplate < ApplicationRecord
  extend FriendlyId

  has_many   :blogs, inverse_of: :template
  belongs_to :author, class_name: 'User'

  friendly_id :name, use: :history, slug_column: :permalink

  enum visibility: {
    private: 'private',
    public: 'public',
    subscriber: 'subscriber'
  }, _suffix: true

  def blog_attributes
    slice(:repo_articles_folder, :repo_drafts_folder, :repo_assets_folder, :repo_readme_path)
  end

  private

  def should_generate_new_friendly_id?
    permalink.blank? || name_changed?
  end

  def resolve_friendly_id_conflict(candidates)
    self.permalink = normalize_friendly_id(name)
  end
end
