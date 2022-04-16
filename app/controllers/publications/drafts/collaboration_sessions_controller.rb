# frozen_string_literal: true

module Publications
  module Drafts
    class CollaborationSessionsController < BaseController
      layout false

      def update
        @collaboration_session = @publication.collaboration_sessions.open.find_by(blob_path: @draft.path)
        authorize! @collaboration_session
        @collaboration_session.update(collaboration_session_params)

        render turbo_stream: turbo_stream.update(helpers.dom_id(@draft, :actions), partial: 'publications/drafts/actions', locals: { publication: @publication, draft: @draft })
      end

      private

      def collaboration_session_params
        params.require(:draft).permit(:current_ydoc, :doc_changed)
      end
    end
  end
end
