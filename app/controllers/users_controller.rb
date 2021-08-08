class UsersController < ApplicationController
  before_action :find_user

  def show
  end

  def edit
  end

  def update
  end

  def destroy
  end

  private

  def find_user
    @user = Current.user
  end
end
