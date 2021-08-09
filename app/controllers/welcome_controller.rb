# frozen_string_literal: true

class WelcomeController < ApplicationController
  include Wicked::Wizard

  steps :confirm_profile, :add_storage, :start_writing, :follow

  def show
    @user = Current.user

    case step
    when :add_storage
      @storage = @user.storages.build
    when :start_writing
      @repo_folders = []
      @blog = @user.blogs.build
    end

    render_wizard
  end
end
