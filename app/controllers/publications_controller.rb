# frozen_string_literal: true

class PublicationsController < ApplicationController
  include AutoCheckable

  before_action :authenticate!, except: :show
  before_action :find_user
  before_action :set_content_partial, only: :show

  def new
  end

  def auto_check
    check_resource_available(resource: @user.publications.new(name: params[:value]), attribute: :name)
  end

  def show
    @publication = @user.publications.friendly.find(params[:permalink])
    redirect_to user_path(@user), notice: t('.personal_publication') if @publication.personal?
  end

  private

  def find_user
    @user = User.friendly.find(params[:user_username])
  end

  def set_content_partial
    @partial = case params[:tab]
               when 'settings' then 'publications/form'
               when 'posts' then 'publications/posts'
               when 'drafts' then 'publications/drafts'
    else 'publications/about'
    end
  end
end
