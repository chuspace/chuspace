# frozen_string_literal: true

class UsersController < ApplicationController
  layout 'user'

  before_action :find_user
  skip_verify_authorized only: :show

  def show
    fresh_when(etag: @user, last_modified: [Current.identity&.updated_at, @user.updated_at].compact.max)
  end

  private

  def find_user
    @user = User.friendly.find(params[:username])
    if params[:username] != @user.username
      redirect_to RedirectUrl.new(path: request.path, params: params).for(@user), status: :moved_permanently
    end
  end
end
