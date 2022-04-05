# frozen_string_literal: true

class AddRepositoryConfigJob < ApplicationJob
  def perform(repository:)
    repository.add_git_repository_config unless repository.config_exists?
  end
end
