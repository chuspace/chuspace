# frozen_string_literal: true

module Publications
  module Drafts
    class PublishingsController < BaseController
      layout false

      def create
        authorize! @draft, to: :publish?
        @post = @draft.publish(author: Current.user)

        if @post
          redirect_to publication_post_path(@publication, @post), notice: 'Successfully published'
        else
          respond_to do |format|
            format.turbo_stream
            format.html { redirect_to publication_edit_draft_path(@publication, @draft) }
          end
        end
      end
    end
  end
end
