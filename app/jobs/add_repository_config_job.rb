# frozen_string_literal: true

class AddRepositoryConfigJob < ApplicationJob
  def perform(publication:)
    unless publication.repository.config_exists?
      publication.git_provider_adapter.create_or_update_blob(
        path: Git::Repository::CONFIG_FILE_PATH,
        content: Base64.encode64(Git::Repository.chuspace_yaml_config),
        message: Git::Repository::CONNECT_MESSAGE,
        committer: Git::Committer.chuspace,
        author: Git::Committer.chuspace
      )
    end
  end
end
