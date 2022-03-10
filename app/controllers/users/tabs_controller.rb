# frozen_string_literal: true

module Users
  class TabsController < BaseController
    skip_before_action :authenticate!

    def show
      @partial = params[:id]
      authorize! @user, to: :show?

      add_breadcrumb(@partial.humanize)

      fail ActiveRecord::RecordNotFoundError if UserTab::PAGES.exclude?(@partial)
    end
  end
end
