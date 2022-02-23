# frozen_string_literal: true

module Publications
  module Drafts
    class EditingLocksController < BaseController
      layout 'blank'

      def show
        authorize! @draft, to: :edit?
        @editing_lock = @publication.editing_locks.find_by(blob_path: @draft.path)
      end

      private

      def autosave_params
        params.require(:draft).permit(:content)
      end
    end
  end
end
