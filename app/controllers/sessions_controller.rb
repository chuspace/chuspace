class SessionsController < ApplicationController
  def index
  end

  def create

  end

  def email
  end

  def destroy
    signout
    redirect_to root_path
  end
end
