# frozen_string_literal: true

module Users
  class DraftsController < BaseController
    prepend_before_action :authenticate!

    def index
      authorize! @user, to: :drafts?

      @path = params[:path] || ''
      add_breadcrumb(:Drafts) if @path.blank?

      if @user.personal_publication.present?
        @drafts_root_path = Pathname.new(@user.personal_publication.repository.drafts_or_posts_folder)
        @draft_path = @drafts_root_path.join(@path).to_s

        if @path.present?
          add_breadcrumb(:Drafts, user_drafts_path(@user))
          add_breadcrumb(@path)
        end

        if turbo_frame_request?
          @drafts = @user.personal_publication.repository.drafts(path: @draft_path) || []
          render partial: 'list', locals: { drafts: @drafts, user: @user }
        end
      end
    end
  end
end
