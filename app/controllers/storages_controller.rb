# frozen_string_literal: true

class StoragesController < ApplicationController
  before_action :find_storage, except: %i[new index create]

  def index
    @storages = Current.user.storages.order(:id)
  end

  def new
    @storage = Current.user.storages.build(provider: :chuspace)
  end

  def create
    Storage.transaction do
      @storage = Current.user.storages.build(storage_params.delete_if { |key, value| value.blank? })

      if params['commit'] && @storage.save
        redirect_to storages_path
      else
        @storage.errors.clear unless params['commit']

        respond_to do |format|
          format.html { render :new }
          format.turbo_stream { render turbo_stream: turbo_stream.replace(@storage, partial: 'storages/form', locals: { storage: @storage }) }
        end
      end
    end
  end

  def edit
  end

  def update
    if @storage.update(storage_params.except(:provider))
      redirect_to storages_path
    else
      respond_to do |format|
        format.html { render :edit }
        format.turbo_stream { render turbo_stream: turbo_stream.replace(@storage, partial: 'storages/form', locals: { storage: @storage }) }
      end
    end
  end

  def destroy
    @storage.destroy

    redirect_to storages_path
  end

  private

  def find_storage
    @storage = Current.user.storages.find(params[:id])
  end

  def storage_params
    params.require(:storage).permit(:description, :endpoint, :provider, :access_token, :default)
  end
end