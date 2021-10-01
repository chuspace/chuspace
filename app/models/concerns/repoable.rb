module Repoable
  extend ActiveSupport::Concern

  included do
    before_create :create_and_connect_git_repo, if: -> { storage.chuspace? && repo_id.blank? }
    after_validation :connect_git_repo, if: -> { storage.external? && !repo_fullname.blank? }
    after_destroy_commit :delete_git_repo, if: -> { storage.chuspace? }
  end

  def repo_folders
    @repo_folders ||= repo_fullname.blank? ? [] : storage.adapter.repository_folders(fullname: repo_fullname)
  end

  private

  def create_and_connect_git_repo
    repository = storage.adapter.create_repository(blog: self)
    self.attributes = repo_hash(repository: repository)
  rescue StandardError
    storage.adapter.delete_repository(fullname: repo_fullname)
  end

  def connect_git_repo
    repository = storage.adapter.repository(fullname: repo_fullname)
    self.attributes = repo_hash(repository: repository)
  end

  def delete_git_repo
    storage.adapter.delete_repository(fullname: repo_fullname)
  end

  def repo_hash(repository:)
    {
      repo_id: repository.id,
      repo_fullname: repository.fullname,
      repo_name: repository.name,
      repo_owner: repository.owner,
      repo_ssh_url: repository.ssh_url,
      repo_html_url: repository.html_url,
      repo_default_branch: repository.default_branch
    }
  end
end
