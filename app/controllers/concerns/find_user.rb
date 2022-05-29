# frozen_string_literal: true

module FindUser
  extend ActiveSupport::Concern

  included do
    before_action :find_user
  end

  private

  def find_user
    @user = User.friendly.find(params[:user_username])
    if params[:user_username] != @user.username
      redirect_to RedirectUrl.new(path: request.path, params: params).for(@user), status: :moved_permanently
    end
    add_breadcrumb(@user.username, user_path(@user))
  end
end
