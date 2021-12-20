# frozen_string_literal: true

class Repository
  attr_reader :blog, :fullname
  delegate :name, :description, :owner, :default_branch, :ssh_url, :html_url, to: :instance

  def initialize(blog:, fullname:)
    @blog = blog
    @fullname = fullname
  end

  def blob(path:, ref: nil)
    @blob ||= blog.storage.adapter.blob(fullname: fullname, path: path, ref: ref)
  end

  def post_blobs
    @post_blobs ||= blog.storage.adapter.blobs(fullname: fullname, folders: blog.posts_folders)
  end

  def asset_blobs
    @asset_blobs ||= blog.storage.adapter.blobs(fullname: fullname, folders: blog.assets_folders)
  end

  def commits(path: nil)
    @commits ||= blog.storage.adapter.commits(fullname: fullname, path: path)
  end

  def commit(sha:)
    @commit ||= blog.storage.adapter.commit(fullname: fullname, sha: sha)
  end

  def files
    @files ||= blog.storage.adapter.repository_files(fullname: fullname)
  end

  def folders
    @folders ||= blog.storage.adapter.repository_folders(fullname: fullname)
  end

  def readme
    content = blog.storage.adapter.blob(fullname: fullname, path: blog.repo_readme_path).content
    @readme ||= Base64.decode64(content) if content
  end

  private

  def instance
    @instance ||= blog.storage.adapter.repository(fullname: fullname)
  end
end
