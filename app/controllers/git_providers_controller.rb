# frozen_string_literal: true

class GitProvidersController < ApplicationController
  before_action :authenticate!

  def setup
    provider = Current.user.git_providers.find_by(name: provider_name)
    authorize! provider

    request.env['omniauth.strategy'].options[:client_id] = provider.client_id
    request.env['omniauth.strategy'].options[:client_secret] = provider.client_secret
    client_options = request.env['omniauth.strategy'].options[:client_options].merge(provider.client_options)
    request.env['omniauth.strategy'].options[:client_options] = client_options

    render plain: 'Omniauth setup phase.', status: 404
  end

  private

  def provider_name
    params[:provider].split('_', 2).first
  end
end
