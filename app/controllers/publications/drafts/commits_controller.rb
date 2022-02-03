# frozen_string_literal: true

module Publications
  module Drafts
    class CommitsController < BaseController
      layout 'blank'

      def new
        add_breadcrumb('Commit')
      end
    end
  end
end
