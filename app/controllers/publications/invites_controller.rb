# typed: ignore
# frozen_string_literal: true

class Publications::InvitesController < ApplicationController
  before_action :authenticate!, except: :accept
  before_action :authenticate, only: :accept
  before_action :find_publication

  skip_verify_authorized only: :accept, if: -> { Current.user.blank? }

  def new
    @invite = @publication.invites.build(sender: Current.user, role: Membership::DEFAULT_ROLE)
    authorize! @invite

    respond_to do |format|
      format.html
      format.turbo_stream
    end
  end

  def create
    @memberships = @publication.memberships.order(:created_at)
    @invite = @publication.invites.build(sender: Current.user, **invite_params)

    authorize! @invite

    respond_to do |format|
      if @invite.save
        format.html do
          redirect_to(
            publication_people_path(@publication),
            notice: t('invites.create.success', identifier: @invite.identifier, publication: @publication.name)
          )
        end
      else
        format.turbo_stream { render turbo_stream: turbo_stream.replace(helpers.dom_id(@invite, :form), partial: 'form', locals: { invite: @invite }) }
        format.html do
          redirect_to publication_people_path(@publication), notice: @invite.errors.full_messages.to_sentence
        end
      end
    end
  end

  def accept
    @invite = @publication.invites.find_by_code(params[:invite_token])

    if @invite
      if Current.user.blank?
        if @invite.recipient.blank?
          redirect_to(
            email_signups_path(return_to: accept_publication_invites_path(@publication, invite_token: @invite.code))
          )
        else
          redirect_to(
            email_sessions_path(return_to: accept_publication_invites_path(@publication, invite_token: @invite.code))
          )
        end
      else
        @invite = @publication.invites.find_by_code(params[:invite_token])
        authorize! @invite

        @publication.memberships.create(role: @invite.role, user: @invite.recipient)
        @invite.destroy

        redirect_to(
          publication_people_path(@publication),
          notice: t('invites.accept.success', publication: @publication.name, role: @invite.role)
        )
      end
    else
      redirect_to publication_path(@publication, error: 'Invitation not found')
    end
  end

  private

  def invite_params
    params.require(:invite).permit(:identifier, :role)
  end

  def find_publication
    @publication = Publication.friendly.find(params[:publication_permalink])
  end
end
