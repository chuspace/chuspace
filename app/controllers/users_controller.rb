# frozen_string_literal: true

class UsersController < ApplicationController
  include Breadcrumbable

  before_action :find_user
  before_action :set_content_partial, only: :show

  def show
  end

  def edit
  end

  def update
    @user.update(user_params)
    redirect_to user_path(@user), notice: 'Sucessfully updated'
  end

  def destroy
  end

  private

  def find_user
    @user = User.friendly.find(params[:username])
  end

  def set_content_partial
    @partial = case params[:tab]
               when 'settings' then 'users/form'
               when 'publications' then 'users/publications'
               when 'drafts' then 'users/drafts'
               when 'posts' then 'users/posts'
    else 'users/overview'
    end
  end

  def user_params
    params.require(:user).permit(:name, :username, :email)
  end
end
