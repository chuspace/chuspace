# frozen_string_literal: true

class Settings::ProfilesController < ApplicationController
  before_action :find_user

  def show
  end

  def edit
    respond_to  do |format|
      format.html
      format.turbo_stream
    end
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
