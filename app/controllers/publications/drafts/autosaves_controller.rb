# frozen_string_literal: true

module Publications
  module Drafts
    class AutosavesController < BaseController
      layout false

      def create
        authorize! @draft

        @draft.collaboration_ydoc.value = autosave_params['ydoc']
        render turbo_stream: turbo_stream.update(helpers.dom_id(@draft, :actions), partial: 'publications/drafts/actions', locals: { publication: @publication, draft: @draft })
      end

      private

      def autosave_params
        params.require(:draft).permit(:ydoc)
      end
    end
  end
end
