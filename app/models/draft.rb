# frozen_string_literal: true

class Draft < Git::Blob
  include Drafts::Yaml
  include Drafts::FrontMatter

  attribute :publication, Publication
  attribute :published, default: proc { false }
  validates :path, :name, markdown: true
  validates :publication, presence: true

  kredis_string :local_content, expires_in: 1.day, key: :local_content_key

  delegate :repository, to: :publication

  after_create :clear_local_content, :store_readme
  after_update :clear_local_content, :store_readme

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

  def publish(author:)
    if post.present?
      post.update(author: author, **to_post_attributes)
    else
      publication.posts.create(author: author, **to_post_attributes)
    end
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
      commit_sha: commits.first&.id || commits.first&.sha
    }
  end

  private

  def local_content_key
    "#{publication.permalink}:#{path}:local_content"
  end

  def clear_local_content
    local_content.value = nil
  end

  def store_readme
    repository.update(readme: decoded_content)
  end
end
