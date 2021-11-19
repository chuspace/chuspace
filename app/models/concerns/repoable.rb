# frozen_string_literal: true

module Repoable
  extend ActiveSupport::Concern

  included do
    before_create :create_and_connect_git_repo, if: -> { storage.chuspace? }
    after_validation :connect_git_repo, if: -> { storage.external? && repository&.name_changed? }
    after_destroy_commit :delete_git_repo, if: -> { storage.chuspace? }
  end

  private

  def create_and_connect_git_repo
    repository = storage.adapter.create_repository(blog: self)
    self.repository = build_repository(name: repository.name)
  rescue StandardError
    storage.adapter.delete_repository(fullname: repository.name)
  end

  def connect_git_repo
    repository = storage.adapter.repository(fullname: repository.name)
    self.name = repository.name
    self.description = repository.description

    self.repository = build_repository(name: repository.name)
  end

  def delete_git_repo
    storage.adapter.delete_repository(fullname: repository.name)
  end
end
