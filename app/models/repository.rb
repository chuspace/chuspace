# frozen_string_literal: true

class Repository
  attr_reader :blog, :fullname
  delegate :name, :description, :owner, :default_branch, :ssh_url, :html_url, to: :instance, allow_nil: true

  def initialize(blog:, fullname:)
    @blog = blog
    @fullname = fullname
  end

  def blob(path:, ref: nil)
    @blob ||= blog.git_provider.adapter.blob(fullname: fullname, path: path, ref: ref)
  end

  def post_blobs
    @post_blobs ||= blog.git_provider.adapter.blobs(fullname: fullname, dirs: blog.posts_dirs)
  end

  def asset_blobs
    @asset_blobs ||= blog.git_provider.adapter.blobs(fullname: fullname, dirs: blog.assets_dirs)
  end

  def commits(path: nil)
    @commits ||= blog.git_provider.adapter.commits(fullname: fullname, path: path)
  end

  def commit(sha:)
    @commit ||= blog.git_provider.adapter.commit(fullname: fullname, sha: sha)
  end

  def files
    @files ||= blog.git_provider.adapter.repository_files(fullname: fullname)
  end

  def dirs
    @dirs ||= blog.git_provider.adapter.repository_dirs(fullname: fullname)
  end

  def webhooks
    @webhooks ||= blog.git_provider.adapter.webhooks(fullname: fullname)
  end

  def readme
    content = blog.git_provider.adapter.blob(fullname: fullname, path: blog.repo_readme_path).content
    @readme ||= Base64.decode64(content).force_encoding('UTF-8') if content
  end

  def instance
    @instance ||= blog.git_provider.adapter.repository(fullname: fullname)
  end
end
