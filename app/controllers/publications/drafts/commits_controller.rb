# frozen_string_literal: true

module Publications
  module Drafts
    class CommitsController < BaseController
      before_action :redirect_to_editing, unless: -> { @draft.stale? }

      layout 'blank'

      def new
        authorize! @draft
        add_breadcrumb('Commit')
      end

      private

      def redirect_to_editing
        redirect_to publication_edit_draft_path(@publication, @draft), notice: 'Nothing to commit!'
      end

      def commit_params
        params.require(:draft).permit(:message)
      end
    end
  end
end
