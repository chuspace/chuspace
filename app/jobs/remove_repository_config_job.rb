# frozen_string_literal: true

class RemoveRepositoryConfigJob < ApplicationJob
  def perform(publication:)
    if publication.repository.config_exists?
      publication.git_provider_adapter.delete_blob(
        path: Git::Repository::CONFIG_FILE_PATH,
        message: Git::Repository::DISCONNECT_MESSAGE,
        committer: Git::Committer.chuspace,
        author: Git::Committer.chuspace
      )
    end
  end
end
