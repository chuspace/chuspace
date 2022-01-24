# frozen_string_literal: true

module Publications
  module Drafts
    class PublishingsController < BaseController
      layout 'publish'

      def new
        @post = @publication.posts.build
        @post.assign_attributes(@draft.post_attributes)
        add_breadcrumb('Publish')
      end
    end
  end
end
