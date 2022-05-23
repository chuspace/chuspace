# frozen_string_literal: true

module Publications
  module Drafts
    class AutosavesController < BaseController
      layout false

      def update
        authorize! @draft, to: :edit?
        @draft.local_content.set_value = commit_params[:content]
        @draft.stale.set_value = commit_params[:stale]

        render turbo_stream: turbo_stream.replace(helpers.dom_id(@draft, :actions), partial: 'publications/drafts/actions', locals: { draft: @draft, publication: @publication })
      end

      private

      def commit_params
        params.require(:draft).permit(:content, :stale)
      end
    end
  end
end
