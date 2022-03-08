# frozen_string_literal: true

module Publications
  module Drafts
    class PublishingsController < BaseController
      before_action :redirect_to_editing, unless: -> { @draft.publishable? }

      layout 'full'

      def new
        authorize! @draft, to: :publish?
        @post = @publication.posts.build
        @post.assign_attributes(@draft.to_post_attributes)
        add_breadcrumb('Publish')
      end

      def create
        authorize! @draft, to: :publish?

        @post = @publication.posts.build(author: Current.user)
        @post.assign_attributes(@draft.to_post_attributes)
        @post.assign_attributes(publish_params)

        if @post.save!
          redirect_to publication_post_path(@publication, @post)
        else
          respond_to do |format|
            format.html { redirect_to publication_new_publish_draft(@publication, @draft) }
            format.turbo_stream { render turbo_stream: turbo_stream.replace(@post, partial: 'form', locals: { draft: @draft, publication: @publication, post: @post }) }
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
