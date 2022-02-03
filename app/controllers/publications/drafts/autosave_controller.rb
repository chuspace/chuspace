# frozen_string_literal: true

module Publications
  module Drafts
    class AutosaveController < BaseController
      layout false

      def show
        add_breadcrumb('Preview')
      end
    end
  end
end
