# frozen_string_literal: true

module Publications
  module Drafts
    class DiffsController < BaseController
      layout 'full'

      def new
        @collaboration_session = @publication.collaboration_sessions.open.find_by(blob_path: @draft.path)
        authorize! @collaboration_session

        respond_to do |format|
          format.html
          format.turbo_stream
        end
      end
    end
  end
end
