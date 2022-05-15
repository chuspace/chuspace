# frozen_string_literal: true

module Publications
  module People
    class ActionsController < BaseController
      def index
        @membership = @publication.memberships.find(params[:person_id])
        authorize! @membership, to: :edit?
        render turbo_stream: turbo_stream.replace(helpers.dom_id(@membership, :actions), partial: 'list', locals: { membership: @membership, publication: @publication })
      end
    end
  end
end
