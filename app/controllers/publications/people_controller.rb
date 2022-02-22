# typed: ignore
# frozen_string_literal: true

module Publications
  class PeopleController < BaseController
    before_action :find_membership, only: %i[update destroy]
    skip_verify_authorized only: :index

    def index
      @publications = Publication.except_personal.limit(5)
      @memberships = @publication.memberships.order(:created_at)
      @invite = @publication.invites.build

      authorize! @publication.memberships.build
    end

    def update
      @membership.update(update_params)
      authorize! @membership

      redirect_to publication_people_path(@publication), notice: t('publications.people.update.success')
    end

    def destroy
      @membership.destroy
      authorize! @membership

      redirect_to publication_people_path(@publication), notice: t('publications.people.destroy.success')
    end

    def autocomplete
      authorize! @publication, to: :invite?

      @query = params[:q]
      @users = User.search(query: @query).with_attached_avatar

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
