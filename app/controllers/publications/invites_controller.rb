# frozen_string_literal: true

module Publications
  class InvitesController < BaseController
    skip_before_action :authenticate!, only: :accept
    before_action :authenticate, only: :accept

    skip_verify_authorized only: :accept, if: -> { Current.user.blank? }

    def index
      authorize! @publication, to: :invite?
      add_breadcrumb(:invites)

      @invites = @publication.invites.pending.order(id: :desc)
      @invite = @publication.invites.build
    end

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

      if @invite.save
        redirect_to(
          publication_invites_path(@publication),
          notice: t('publications.invites.create.notice', identifier: @invite.identifier, publication: @publication.name)
        )
      else
        respond_to do |format|
          format.turbo_stream { render turbo_stream: turbo_stream.replace(helpers.dom_id(@invite, :form), partial: 'form', locals: { invite: @invite }) }
          format.html do
            redirect_to publication_people_path(@publication), notice: @invite.errors.full_messages.to_sentence
          end
        end
      end
    end

    def resend
      @invite = @publication.invites.find_by(code: params[:id])
      authorize! @invite, to: :create?
      @invite.send_email

      respond_to do |format|
        format.turbo_stream { render turbo_stream: turbo_stream.replace(helpers.dom_id(@invite), partial: 'invite', locals: { invite: @invite }) }
        format.html do
          redirect_to publication_invites_path(@publication), notice: @invite.errors.full_messages.to_sentence
        end
      end
    end

    def destroy
      @invite = @publication.invites.find_by(code: params[:id])
      authorize! @invite, to: :destroy?
      @invite.destroy

      redirect_to publication_invites_path(@publication), notice: @invite.errors.full_messages.to_sentence || t('publications.invites.destroy.notice')
    end

    def accept
      @invite = @publication.invites.find_by_code(params[:invite_token])

      Invite.transaction do
        if @invite
          if Current.user.blank?
            store_location_for(:user, accept_publication_invites_path(@publication, invite_token: @invite.code))

            if @invite.recipient.blank?
              redirect_to email_signups_path(email: @invite.recipient_email)
            else
              redirect_to email_sessions_path(email: @invite.recipient.email)
            end
          else
            @invite = @publication.invites.find_by_code(params[:invite_token])
            authorize! @invite

            @publication.memberships.create(role: @invite.role, user: @invite.recipient)
            @invite.destroy

            redirect_to(
              publication_people_path(@publication),
              notice: t('publications.invites.accept.notice', publication: @publication.name, role: @invite.role)
            )
          end
        else
          redirect_to publication_path(@publication), alert: t('publications.invites.accept.not_found')
        end
      end
    end

    private

    def invite_params
      params.require(:invite).permit(:identifier, :role)
    end
  end
end
