# frozen_string_literal: true

module Publications
  class AssetsController < BaseController
    include ActiveStorage::Streaming

    def show
      @blob = @publication.repository.asset(path: CGI.unescape(params[:path]))
      send_data Base64.decode64(@blob.content), disposition: params[:disposition], filename: @blob.name
    end

    def create
      image = @publication.repository.git_adapter.create_or_update_blob(
        path: File.join(@publication.repo.assets_folder, params[:image].original_filename),
        content: Base64.encode64(params[:image].read),
        sha: '',
        committer: GitConfig.new.committer,
        author: {
          name: Current.user.name,
          email: Current.user.email,
          date: Date.today
        }
      )

      render json: { url: publication_asset_path(@publication, path: image.content.path) }
    end
  end
end
