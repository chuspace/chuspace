# frozen_string_literal: true

module Posts
  class PublishingsController < BaseController
    skip_verify_authorized
    skip_before_action :authenticate!

    layout :select_layout

    def index
      @publishings = @post.publishings

      respond_to do |format|
        format.turbo_stream { render turbo_stream: turbo_stream.replace(helpers.dom_id(@draft, :actions), partial: 'publications/drafts/actions', locals: { draft: @draft, publication: @publication }) }
        format.html
      end
    end

    def show
      @publishing = @post.publishings.find_by(version: params[:id])

      if @post.current_publishing == @publishing
        redirect_to publication_post_path(@publication, @post), status: :moved_permanently
      end
    end

    private

    def select_layout
      case action_name
      when 'index' then false
      when 'show' then 'publishing'
      end
    end
  end
end
