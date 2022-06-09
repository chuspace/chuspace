# frozen_string_literal: true

module Publications
  module Drafts
    class AutosavesController < BaseController
      layout false

      def update
        authorize! @draft, to: :edit?
        @draft.local_content.set_value = commit_params[:content]
        @draft.stale.set_value = commit_params[:stale]

        respond_to do |format|
          format.turbo_stream
        end
      end

      private

      def commit_params
        params.require(:draft).permit(:content, :stale)
      end
    end
  end
end
