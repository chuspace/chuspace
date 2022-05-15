# frozen_string_literal: true

class PublicationsController < ApplicationController
  include AutoCheckable
  before_action :authenticate!, only: :new
  skip_verify_authorized except: :new

  def index
    @publications = Publication.except_personal.limit(10)
  end

  def auto_check
    check_resource_available(resource: Publication.new(name: params[:value]), attribute: :name)
  end

  def show
    @publication = Publication.friendly.find(params[:permalink])
    @invite = @publication.invites.build(sender: Current.user, role: Membership::DEFAULT_ROLE)

    redirect_to @publication, status: :moved_permanently if params[:permalink] != @publication.permalink
  end
end
