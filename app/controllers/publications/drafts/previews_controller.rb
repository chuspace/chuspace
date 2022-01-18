# frozen_string_literal: true

module Publications
  module Drafts
    class PreviewsController < BaseController
      def show
        @path = params[:path]
        add_breadcrumb('Preview')
      end
    end
  end
end
