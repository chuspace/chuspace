# frozen_string_literal: true

module Connect
  class OtherPublicationsController < BaseController
    private

    def create_publication_path
      create_connect_other_publication_path(@git_provider, repo_fullname: @publication.repo.fullname)
    end
  end
end
