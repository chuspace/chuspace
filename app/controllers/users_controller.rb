# frozen_string_literal: true

class UsersController < ApplicationController
  before_action :find_user
  before_action :set_content_partial

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
    @user = Current.user
  end

  def set_content_partial
    @partial = case params[:tab]
               when 'settings' then 'users/form'
               when 'storages' then 'users/storages'
               when 'blogs' then 'users/blogs'
               when 'articles' then 'users/articles'
    else
                 @markdown_doc ||= CommonMarker.render_doc(@user.about_readme || '')
      'users/about'
    end
  end

  def user_params
    params.require(:user).permit(:name, :username)
  end
end
