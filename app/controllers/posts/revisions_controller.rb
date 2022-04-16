# frozen_string_literal: true

module Posts
  class RevisionsController < ApplicationController
    before_action :authenticate!
    before_action :find_publication, :find_post
    before_action :find_revision, only: %i[edit show update]

    layout 'post'

    def index
      authorize! @post
    end

    def create
      authorize! @post.revisions.build(author: Current.user, publication: @publication)
      @revision = @post.revisions.open.find_or_create_by(author: Current.user, publication: @publication)

      if @revision.persisted?
        redirect_to edit_publication_post_revision_path(@publication, @post, @revision)
      else
        redirect_to publication_post_path(@publication, @post), notice: 'Something went wrong!'
      end
    end

    def update
      authorize! @revision
      @revision.update(revision_params)

      # render turbo_stream: turbo_stream.update(helpers.dom_id(@draft, :revisions), partial: 'publications/revision/actions', locals: { publication: @publication, revision: @revision })
    end

    private

    def revision_params
      params.require(:draft).permit(:title)
    end

    def find_revision
      @revision = @post.find_or_start_revision(user: Current.user, blob_path: @post.blob_path)
    end

    def find_post
      @post = @publication.posts.friendly.find(params[:post_permalink])
    end

    def find_publication
      @publication = Publication.friendly.find(params[:publication_permalink])
    end
  end
end
