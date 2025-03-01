# frozen_string_literal: true

class PublicationsController < ApplicationController
  before_action :authenticate!, only: :new
  after_action :track_action, only: :show

  skip_verify_authorized except: :new

  def show
    @publication = Publication.friendly.find(params[:permalink])

    if params[:permalink] != @publication.permalink
      redirect_to RedirectUrl.new(path: request.path, params: params).for(@publication), status: :moved_permanently
    end

    @invite = @publication.invites.build(sender: Current.user, role: Membership::DEFAULT_ROLE)
  end

  private

  def track_action
    MaybeLater.run do
      ActiveRecord::Base.connected_to(role: :writing) do
        ahoy.track 'view:publication', request.path_parameters.merge(publication_id: @publication.id)
      end
    end
  end
end
