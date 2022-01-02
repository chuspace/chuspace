# frozen_string_literal: true

class StarterTemplate < ApplicationRecord
  extend FriendlyId

  has_many   :blogs, inverse_of: :template
  belongs_to :author, class_name: 'User', optional: true

  friendly_id :name, use: :history, slug_column: :permalink

  enum visibility: {
    private: 'private',
    public: 'public',
    subscriber: 'subscriber'
  }, _suffix: true

  def blog_attributes
    slice(:repo_posts_dir, :repo_drafts_dir, :repo_assets_dir, :repo_readme_path)
  end

  private

  def should_generate_new_friendly_id?
    permalink.blank? || name_changed?
  end

  def resolve_friendly_id_conflict(candidates)
    self.permalink = normalize_friendly_id(name)
  end
end
