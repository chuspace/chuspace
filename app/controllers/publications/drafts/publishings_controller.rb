# frozen_string_literal: true

module Publications
  module Drafts
    class PublishingsController < BaseController
      layout false

      def new
        authorize! @draft, to: :publish?
        @post = @publication.posts.build(author: Current.user)
        @publishing = @post.publishings.build(author: Current.user)
      end

      def create
        authorize! @draft, to: params[:republish] ? :republish? : :publish?
        @post = @draft.post ||  @publication.posts.build(author: Current.user)
        @post.assign_attributes(@draft.to_post_attributes)

        if @post.save
          @post.publishings.create(author: Current.user, current: true, version: @post.publishings.count + 1, content: @draft.decoded_content, commit_sha: @post.commit_sha, **publishing_params)
          redirect_to publication_post_path(@publication, @post), notice: 'Successfully published!'
        else
          respond_to do |format|
            format.turbo_stream { render turbo_stream: turbo_stream.replace(helpers.dom_id(@draft, :actions), partial: 'publications/drafts/actions', locals: { draft: @draft, publication: @publication }) }
            format.html { redirect_to publication_edit_draft_path(@publication, @draft), notice: @post.errors.full_messages.to_sentence }
          end
        end
      end

      private

      def publishing_params
        params.require(:publishing).permit(:description)
      end
    end
  end
end
