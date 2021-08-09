# frozen_string_literal: true

class Settings::StoragesController < ApplicationController
  def index
    @storages = Current.user.storages
  end

  def new
    @storage = Current.user.storages.build

    respond_to do |format|
      format.turbo_stream
      format.html
    end
  end

  def create
    @storage = Current.user.storages.build(storage_params)

    if @storage.save
      redirect_to storages_path
    else
      redirect_to new_storage_path
    end
  end

  private

  def storage_params
    params.require(:storage).permit(:provider, :access_token, :default)
  end
end
