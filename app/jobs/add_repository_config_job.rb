# frozen_string_literal: true

class AddRepositoryConfigJob < ApplicationJob
  def perform(repository:)
    unless repository.config_exists?
      repository.git_provider_adapter.create_blob(
        path: Repository::CONFIG_FILE_PATH,
        content: Base64.encode64(Repository.chuspace_yaml_config),
        message: Repository::CONNECT_MESSAGE,
        committer: Git::Committer.chuspace,
        author: Git::Committer.chuspace
      )
    end
  end
end
