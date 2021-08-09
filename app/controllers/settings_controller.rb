# frozen_string_literal: true

class SettingsController < ApplicationController
  def index
    redirect_to setting_path(id: :profile)
  end

  def show
  end
end
