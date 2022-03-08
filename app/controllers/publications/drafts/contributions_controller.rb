# frozen_string_literal: true

module Publications
  module Drafts
    class ContributionsController < BaseController
      layout :choose_layout

      def index
        authorize! @draft
        add_breadcrumb('contribute')
      end

      def new
        authorize! @draft
      end

      def create
        authorize! @draft
      end

      private

      def choose_layout
        action_name == 'index' ? 'post' : false
      end
    end
  end
end
