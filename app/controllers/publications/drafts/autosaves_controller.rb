# frozen_string_literal: true

module Publications
  module Drafts
    class AutosavesController < BaseController
      layout 'blank'

      def create
        @draft.local_content.value = autosave_params['content']
        head :ok
      end

      private

      def autosave_params
        params.require(:draft).permit(:content)
      end
    end
  end
end
