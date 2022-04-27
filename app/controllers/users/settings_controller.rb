# frozen_string_literal: true

module Users
  class SettingsController < BaseController
    layout 'application'

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
      puts user_params.inspect
      @user.update(user_params)
      @user.avatar.attach(user_params[:avatar])

      redirect_to user_setting_path(@user, id: params[:id])
    end

    private

    def user_params
      params.require(:user).permit(:name, :email, :avatar)
    end
  end
end
