# frozen_string_literal: true

class PublicationsController < ApplicationController
  include AutoCheckable

  before_action :authenticate!, except: :show
  before_action :set_content_partial, only: :show

  def new
  end

  def auto_check
    check_resource_available(resource: Publication.new(name: params[:value]), attribute: :name)
  end

  def show
    @publication = Publication.friendly.find(params[:permalink])
  end

  private

  def set_content_partial
    @partial = case params[:tab]
               when 'settings' then 'publications/form'
               when 'posts' then 'publications/posts'
               when 'drafts' then 'publications/drafts'
    else 'publications/about'
    end
  end
end
