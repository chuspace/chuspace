class Template < ApplicationRecord
  belongs_to :author, class_name: 'User'
  belongs_to :storage
  before_validation :set_permalink

  def blog_attributes
    {
      repo_articles_path: articles_folder,
      repo_drafts_path: drafts_folder,
      repo_assets_path: assets_folder
    }
  end

  private

  def set_permalink
    self.permalink = name.to_slug.normalize.to_s
  end
end
