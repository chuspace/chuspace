# frozen_string_literal: true

module Publications
  module Drafts
    class CommitsController < BaseController
      layout 'editor'

      def new
        authorize! @draft, to: :commit?
      end

      private

      def commit_params
        params.require(:draft).permit(:message)
      end
    end
  end
end
