# frozen_string_literal: true

class UsersController < ApplicationController
  layout 'user'

  before_action :find_user
  skip_verify_authorized only: :show

  private

  def find_user
    @user = User.friendly_fetch!(params[:username])
    if params[:username] != @user.username
      redirect_to RedirectUrl.new(path: request.path, params: params).for(@user), status: :moved_permanently
    end
  end
end
