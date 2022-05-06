# frozen_string_literal: true

module Publications
  module Drafts
    class AutosavesController < BaseController
      layout false

      def update
        authorize! @draft, to: :edit?
        @draft.local_content.value = commit_params[:content] if commit_params[:content].present?

        render turbo_stream: turbo_stream.replace(helpers.dom_id(@draft, :actions), partial: 'publications/drafts/actions', locals: { draft: @draft, publication: @publication })
      end

      private

      def commit_params
        params.require(:draft).permit(:content)
      end
    end
  end
end
