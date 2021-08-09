# frozen_string_literal: true

class StoragesController < ApplicationController
  before_action :find_storage, except: :create

  def create
    @storage = Current.user.storages.build(storage_params)

    if @storage.save
      redirect_to setting_path(id: :storage)
    else
      redirect_to new_storage_path
    end
  end

  def edit
  end

  def destroy
    @storage.destroy

    respond_to do |format|
      format.turbo_stream { render turbo_stream: turbo_stream.remove(@storage) }
      format.html { redirect_to setting_path(id: :storage) }
    end
  end

  private

  def find_storage
    @storage = Current.user.storages.find(params[:id])
  end

  def storage_params
    params.require(:storage).permit(:provider, :access_token, :default)
  end
end
