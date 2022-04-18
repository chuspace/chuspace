# frozen_string_literal: true

module Connect
  class OtherPublicationsController < BaseController
    private

    def create_publication_path
      create_connect_other_publication_path(@git_provider, repo_fullname: @publication.repository.full_name)
    end

    def partial_name
      'connect/other_publications/form'
    end
  end
end
