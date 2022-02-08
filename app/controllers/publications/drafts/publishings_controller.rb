# frozen_string_literal: true

module Publications
  module Drafts
    class PublishingsController < BaseController
      layout 'blank'

      def new
        @post = @publication.posts.build
        @post.assign_attributes(@draft.to_post_attributes)
        add_breadcrumb('Publish')
      end

      def create
        @post = @publication.posts.build
        @post.assign_attributes(@draft.to_post_attributes)
        @post.assign_attributes(publish_params)

        if @post.save!
          redirect_to publication_post_path(@publication, @post)
        end
      end

      private

      def publish_params
        params.require(:post).permit(:visibility, :date, :topic_list)
      end
    end
  end
end
