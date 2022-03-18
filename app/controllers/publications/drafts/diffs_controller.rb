# frozen_string_literal: true

module Publications
  module Drafts
    class DiffsController < BaseController
      layout 'full'

      def new
        authorize! @draft
        @ydoc = @draft.collaboration_ydoc

        respond_to do |format|
          format.html
          format.turbo_stream
        end
      end
    end
  end
end
