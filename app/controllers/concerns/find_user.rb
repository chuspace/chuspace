# frozen_string_literal: true

module FindUser
  extend ActiveSupport::Concern

  included do
    before_action :find_user
  end

  def find_user
    @user = User.friendly.find(params[:user_username])
    add_breadcrumb(@user.username, user_path(@user))
  end
end
