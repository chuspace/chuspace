# frozen_string_literal: true

module Users
  class DraftsController < BaseController
    def index
      authorize! @user, to: :drafts?

      add_breadcrumb(:drafts, user_drafts_path(@user))

      if @user.personal_publication.present?
        @drafts_root_path = Pathname.new(@user.personal_publication.repository.drafts_or_posts_folder)
        @path = params[:path] || ''
        add_breadcrumb(@path, nested_user_drafts_path(@user, path: @path)) if @path.present?
        @draft_path ||= @drafts_root_path.join(@path).to_s

        if turbo_frame_request?
          @drafts = @user.personal_publication.repository.drafts(path: @draft_path) || []
          render partial: 'list', locals: { drafts: @drafts, user: @user }
        end
      end
    end
  end
end
