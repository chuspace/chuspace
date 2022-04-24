# frozen_string_literal: true

module Publications
  module Drafts
    class CommitsController < BaseController
      layout 'editor'

      before_action :redirect_to_editing, unless: -> { @draft.collaboration_session&.doc_changed? }

      def new
        authorize! @draft, to: :commit?
        @collaboration_session = @publication.collaboration_sessions.find_by(blob_path: @draft.path)
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
