# frozen_string_literal: true

class ReposController < ApplicationController
  def index
    @storage = Current.user.storages.find(params[:storage_id])
    query = case @storage.provider
            when 'github' then "#{params[:q]} user:#{@storage.provider_user.login}"
            else params[:q]
    end

    @repositories = @storage.adapter.search_repositories(query: query)

    respond_to do |format|
      format.json
      format.html_fragment
    end
  end
end
