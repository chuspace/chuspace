# frozen_string_literal: true

class Draft < Git::Blob
  include Drafts::Markdown
  include Drafts::FrontMatter # Depends on Markdown

  attribute :publication, Publication
  attribute :published, default: proc { false }
  validates :path, :name, markdown: true
  validates :publication, presence: true

  kredis_string :local_content, expires_in: 1.day, key: :local_content_key

  delegate :repository, to: :publication

  after_create :auto_publish_post, :clear_local_content, :parse_and_store_readme
  after_update :auto_publish_post, :clear_local_content, :parse_and_store_readme

  def body
    parsed.content
  end

  def decoded_content
    Base64.decode64(content).force_encoding('UTF-8')
  end

  def local_or_remote_content
    local_content.value.presence || decoded_content
  end

  def post
    @post ||= publication.posts.find_by(blob_path: path)
  end

  def publishable?
    post&.blob_sha != sha && !readme?
  end

  def persisted?
    id.present?
  end

  def readme?
    repository.readme_path == path
  end

  def reload!
    self.assign_attributes(repository.draft(path: path).attributes)
  end

  def relative_path
    if readme?
      path
    else
      base_path = Pathname.new(repository.posts_folder)
      file_path = Pathname.new(path)
      file_path.relative_path_from(base_path).to_s
    end
  end

  def stale?
    local_content.value.present? && local_content.value != decoded_content
  end

  def status
    if stale? then 'Uncommitted changes'
    elsif publishable? then 'Unpublished changes'
    else 'Everything up to date'
    end
  end

  def to_param
    relative_path
  end

  def to_post_attributes
    {
      date: date || Date.today,
      title: title,
      summary: summary,
      topic_list: topics,
      blob_path: path,
      blob_sha: id,
      body: body,
      body_html: content_html,
      commit_sha: commits.first&.id || commits.first&.sha
    }
  end

  private

  def local_content_key
    "#{publication.permalink}:#{path}:content"
  end

  def auto_publish_post
    if publication.content.auto_publish && publishable?
      self.published = true if publication.posts.create(author: Current.user, **to_post_attributes)
    end
  end

  def clear_local_content
    local_content.value = nil
  end

  def parse_and_store_readme
    repository.update(readme: content_html)
  end
end
