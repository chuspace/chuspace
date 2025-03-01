# frozen_string_literal: true

module Posts
  class RevisionsController < BaseController
    before_action :find_revision, only: %i[edit show update]

    layout false

    def index
      authorize! @post
      render json: { revisions: RevisionResource.new(@post.revisions).serialize }
    end

    def create
      authorize! @post.revisions.build(author: Current.user, publication: @publication)
      revisions = @post.revisions.open.create(create_params)

      if revisions
        render json: { revisions: RevisionResource.new(revisions).serialize }
      else
        render json: { revisions: [] }
      end
    end

    def update
      authorize! @revision

      if @revision.update(update_params)
        render json: { revision: RevisionResource.new(@revision).serialize }
      else
        render json: { revision: false }
      end
    end

    private

    def create_params
      params[:revisions].map do |revision_param|
        revision_param[:publication_id] = @publication.id
        revision_param[:post_id] = @post.id
        revision_param[:author_id] = Current.user.id
        attributes = ActionController::Parameters.new(revision: revision_param.deep_transform_keys(&:downcase))
        attributes.require(:revision).permit(:publication_id, :post_id, :author_id, :pos_from, :pos_to, :content_before, :content_after, :widget_pos, node: {})
      end
    end

    def update_params
      params.require(:revision).permit(:status)
    end

    def find_revision
      @revision = @post.revisions.find(params[:id])
    end
  end
end
