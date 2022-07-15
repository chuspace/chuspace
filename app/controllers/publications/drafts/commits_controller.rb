# frozen_string_literal: true

module Publications
  module Drafts
    class CommitsController < BaseController
      layout false

      def new
        authorize! @draft, to: :commit?
      end
    end
  end
end
