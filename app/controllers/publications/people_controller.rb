# typed: ignore
# frozen_string_literal: true

module Publications
  class PeopleController < BaseController
    before_action :find_membership, only: %i[edit destroy update]
    skip_verify_authorized only: :index

    def index
      @memberships = @publication.memberships.order(:created_at)
      @invite = @publication.invites.build

      authorize! @publication.memberships.build
    end

    def update
      authorize! @membership

      if @membership.update(update_params)
        redirect_to publication_people_path(@publication), notice: t('publications.people.update.notice')
      else
        respond_to do |format|
          format.turbo_stream { render turbo_stream: turbo_stream.replace(helpers.dom_id(@membership, :form), partial: 'form', locals: { membership: @membership }) }
          format.html do
            redirect_to publication_people_path(@publication), notice: @membership.errors.full_messages.to_sentence
          end
        end
      end
    end

    def edit
      authorize! @membership
    end

    def destroy
      authorize! @membership
      @membership.destroy

      redirect_to publication_people_path(@publication), notice: t('publications.people.destroy.notice')
    end

    def autocomplete
      authorize! @publication, to: :invite?

      @query = params[:q]
      @users = User.search(@query).with_attached_avatar

      respond_to { |type| type.html_fragment { render partial: 'publications/people/autocomplete' } }
    end

    private

    def update_params
      params.require(:membership).permit(:role)
    end

    def find_membership
      @membership = @publication.memberships.find(params[:id])
    end
  end
end
