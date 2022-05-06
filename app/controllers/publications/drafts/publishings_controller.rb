# frozen_string_literal: true

module Publications
  module Drafts
    class PublishingsController < BaseController
      layout false

      def new
        authorize! @draft, to: :publish?
        @post = @publication.posts.build
        @post.assign_attributes(@draft.to_post_attributes)
      end

      def create
        authorize! @draft, to: :publish?
        @post = @draft.publish(author: Current.user, other_attributes: publish_params)

        if @post
          redirect_to publication_post_path(@publication, @post)
        else
          respond_to do |format|
            format.html { redirect_to publication_new_publish_draft(@publication, @draft) }
            format.turbo_stream {
 render turbo_stream: turbo_stream.replace(@post, partial: 'form',
locals: { draft: @draft, publication: @publication, post: @post }) }
          end
        end
      end

      private

      def publish_params
        params.require(:post).permit(:visibility, :date, :topic_list)
      end
    end
  end
end
