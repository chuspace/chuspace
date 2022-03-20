# frozen_string_literal: true

module Publications
  module Drafts
    class AutosavesController < BaseController
      layout false

      def create
        @collaboration_session = @publication.collaboration_sessions.active.find_by(blob_path: @draft.path)
        authorize! @collaboration_session

        @collaboration_session.update(autosave_params)
        render turbo_stream: turbo_stream.update(helpers.dom_id(@draft, :actions), partial: 'publications/drafts/actions', locals: { publication: @publication, draft: @draft })
      end

      private

      def autosave_params
        params.require(:draft).permit(:current_ydoc)
      end
    end
  end
end
