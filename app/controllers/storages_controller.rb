# frozen_string_literal: true

class StoragesController < ApplicationController
  before_action :find_storage, except: %i[new create]

  def index
    @storages = Current.user.storages
  end

  def new
    @storage = Current.user.storages.build(provider: :github)

    respond_to do |format|
      format.turbo_stream
      format.html
    end
  end

  def create
    @storage = Current.user.storages.create(storage_params.delete_if { |key, value| value.blank? })
    redirect_to settings_storages_path
  end

  def edit
  end

  def update
    @storage.update(storage_params.except(:provider))

    redirect_to settings_storages_path
  end

  def destroy
    @storage.destroy

    redirect_to settings_storages_path
  end

  private

  def find_storage
    @storage = Current.user.storages.find(params[:id])
  end

  def storage_params
    params.require(:storage).permit(:description, :endpoint, :provider, :access_token, :default)
  end
end
