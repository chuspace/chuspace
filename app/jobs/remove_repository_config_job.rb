# frozen_string_literal: true

class RemoveRepositoryConfigJob < ApplicationJob
  def perform(repository:)
    repository.remove_git_repository_config if repository.config_exists?
  end
end
