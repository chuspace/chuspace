# frozen_string_literal: true

module Publications
  module Drafts
    class PreviewsController < BaseController
      layout 'post'

      def show
        authorize! @draft
        add_breadcrumb('Preview')
      end
    end
  end
end