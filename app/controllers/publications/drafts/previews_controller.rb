# frozen_string_literal: true

module Publications
  module Drafts
    class PreviewsController < BaseController
      layout 'post'

      def show
        authorize! @draft
      end
    end
  end
end
