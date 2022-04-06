# frozen_string_literal: true

class RemoveRepositoryConfigJob < ApplicationJob
  def perform(repository:)
    if repository.config_exists?
      repository.git_provider_adapter.delete_blob(
        path: Repository::CONFIG_FILE_PATH,
        message: Repository::DISCONNECT_MESSAGE,
        committer: Git::Committer.chuspace,
        author: Git::Committer.chuspace
      )
    end
  end
end
