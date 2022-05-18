# frozen_string_literal: true

module Publications
  class AssetsController < BaseController
    include ActiveStorage::Streaming, SetPublicationRoot
    before_action :set_assets_root_path, :set_asset_path

    def index
      authorize! @publication, to: :write?
      add_breadcrumb(:assets)

      if turbo_frame_request?
        @assets = @publication.repository.assets(path: @asset_path)
        render partial: 'list', locals: { assets: @assets, publication: @publication }
      end
    end

    def show
      authorize! @publication, to: :show?
      data = @publication.repository.raw(path: params[:path])
      expires_in 1.year, public: true
      send_data data, disposition: :inline, filename: File.basename(params[:path])
    end

    def create
      extname = File.extname(params[:image].original_filename)
      filename = File.basename(params[:image].original_filename, '.*')
      normalized_name = filename.to_slug.normalize.to_s + extname
      path = @assets_root_path.join(normalized_name).to_s

      unless @publication.repository.blob_exists?(path: path)
        @asset = Asset.new(
          name: normalized_name,
          publication: @publication,
          adapter: @publication.repository.git_provider_adapter,
          path: path
        )

        authorize! @publication, to: :write?
        @asset.create(content: params[:image].read, author: Git::Committer.for(user: Current.user))
      end

      render json: { url: File.join('/', path) }
    end

    def destroy
      authorize! @publication, to: :write?
      @asset = @publication.repository.asset(path: CGI.unescape(params[:path]))
      @asset.delete(**commit_params)
    end

    private

    def set_assets_root_path
      @assets_root_path = Pathname.new(@publication.repository.assets_folder)
    end

    def set_asset_path
      @path = params[:path] || ''
      @asset_path = @assets_root_path.join(@path).to_s
    end
  end
end
