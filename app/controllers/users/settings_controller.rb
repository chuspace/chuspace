# frozen_string_literal: true

module Users
  class SettingsController < BaseController
    def index
      authorize! @user, to: :edit?

      redirect_to user_setting_path(@user, id: UserSetting::DEFAULT_PAGE)
    end

    def show
      @partial = params[:id]
      authorize! @user, to: :edit?

      add_breadcrumb(t("users.settings.show.#{@partial}.title"))

      fail ActiveRecord::RecordNotFoundError if UserSetting::PAGES.exclude?(@partial)
    end

    def update
      authorize! @user, to: :edit?
      @user.update(user_params)

      redirect_to user_setting_path(@user, id: params[:id])
    end

    private

    def user_params
      params.require(:user).permit(
        :name,
        :description,
        :icon,
        repo_attributes: %i[posts_folder drafts_folder assets_folder readme_path]
      )
    end
  end
end
