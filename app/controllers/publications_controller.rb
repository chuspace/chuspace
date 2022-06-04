# frozen_string_literal: true

class PublicationsController < ApplicationController
  before_action :authenticate!, only: :new
  skip_verify_authorized except: :new

  def show
    @publication = Publication.friendly.find(params[:permalink])

    if params[:permalink] != @publication.permalink
      redirect_to RedirectUrl.new(path: request.path, params: params).for(@publication), status: :moved_permanently
    end

    @invite = @publication.invites.build(sender: Current.user, role: Membership::DEFAULT_ROLE)
    fresh_when(etag: @publication, last_modified: [Current.identity&.updated_at, @publication.updated_at].compact.max)
  end
end
