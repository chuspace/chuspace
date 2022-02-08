# frozen_string_literal: true

module Publications
  module Drafts
    class CommitsController < BaseController
      layout 'blank'

      def new
        add_breadcrumb('Commit')
      end

      private

      def commit_params
        params.require(:draft).permit(:message)
      end
    end
  end
end
