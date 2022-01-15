# frozen_string_literal: true

module Publications
  class DraftsController < ApplicationController
    before_action :find_user, :find_publication
    before_action :find_draft, only: %w[update edit destroy]

    layout 'editor', only: :edit

    def show
      @path = params[:path]
    end

    def edit
    end

    private

    def find_draft
      @draft = @publication.git_repository.draft(path: params[:path])
    end

    def find_publication
      @publication = @user.publications.friendly.find(params[:publication_permalink])
    end

    def find_user
      @user = User.friendly.find(params[:user_username])
    end
  end
end
