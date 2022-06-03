# frozen_string_literal: true

class SettingsController < ApplicationController
  include Breadcrumbable
  before_action :authenticate!, :set_user

  def index
    authorize! @user, to: :edit?

    redirect_to setting_path(id: UserSetting::DEFAULT_PAGE)
  end

  def show
    @partial = params[:id]
    authorize! @user, to: :edit?

    add_breadcrumb(t("users.settings.show.#{@partial}.title"))

    fail ActiveRecord::RecordNotFound if UserSetting::PAGES.exclude?(@partial)
  end

  def update
    @user = User.find(Current.user.id)
    authorize! @user, to: :edit?

    if @user.update(user_params)
      redirect_to setting_path(id: params[:id]), notice: t('users.settings.update.success')
    else
      respond_to do |format|
        format.html { redirect_to setting_path(id: params[:id]), error: t('users.settings.update.failure') }
        format.turbo_stream { render turbo_stream: turbo_stream.replace(helpers.dom_id(@user, params[:id].to_sym), partial: 'profile', locals: { user: @user }) }
      end
    end
  end

  private

  def set_user
    @user = Current.user
  end

  def user_params
    params.require(:user).permit(:name, :email, :avatar)
  end
end
