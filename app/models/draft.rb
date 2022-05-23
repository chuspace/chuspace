# frozen_string_literal: true

class Draft < Git::Blob
  include Keyable
  include Drafts::Yaml
  include Drafts::FrontMatter

  attribute :publication, Publication
  attribute :published, default: proc { false }
  validates :path, :name, markdown: true
  validates :publication, presence: true

  kv_string  :local_content, expires_in: 1.day
  kv_boolean :stale, expires_in: 1.day

  delegate :repository, to: :publication

  after_create :clear_local_content, :store_repository_readme
  after_update :clear_local_content, :store_repository_readme

  def body
    parsed.content
  end

  def local_or_remote_content
    local_content.value.presence || decoded_content
  end

  def post
    publication.posts.find_by(blob_path: path)
  end

  def publishable?
    post&.blob_sha != sha && !readme?
  end

  def publish(author:)
    if post.present?
      post.update(author: author, **to_post_attributes)
      post
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
    stale.value
  end

  def status
    if stale? then 'Uncommitted changes'
    elsif publishable? then 'Unpublished changes'
    else 'Up to date'
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

  def kv_key_prefix
    "#{publication.permalink}:#{path}"
  end

  def clear_local_content
    local_content.clear
  end

  def store_repository_readme
    repository.update(readme: decoded_content) if readme?
  end
end
