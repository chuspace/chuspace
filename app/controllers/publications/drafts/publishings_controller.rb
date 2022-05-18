# frozen_string_literal: true

module Publications
  module Drafts
    class PublishingsController < BaseController
      layout false

      def create
        authorize! @draft, to: :publish?
        @post = @draft.publish(author: Current.user)

        if @post.save
          redirect_to publication_post_path(@publication, @post), notice: 'Successfully published'
        else
          redirect_to publication_edit_draft_path(@publication, @draft), notice: 'Something went wrong!'
        end
      end
    end
  end
end
