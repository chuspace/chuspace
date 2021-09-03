# frozen_string_literal: true

class SettingsController < ApplicationController
  layout 'settings'

  def index
    redirect_to settings_profiles_path
  end
end
