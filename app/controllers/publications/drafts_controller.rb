# frozen_string_literal: true

module Publications
  class DraftsController < ApplicationController
    include Breadcrumbable, SetPublicationRoot
    before_action :find_draft, only: %w[update edit destroy]

    layout 'editor', only: %i[new edit]

    def index
      if turbo_frame_request?
        @drafts = @publication.drafts(path: @draft_path)
        render partial: 'list', locals: { drafts: @drafts, publication: @publication }
      end
    end

    def create
      @commit = Git::Commit.new(
        author: Git::Author.for(user: Current.user),
        committer: Git::Committer.chuspace,
        message: draft_params[:commit_message],
        adapter: @publication.git_provider_adapter
      )

      @draft = Draft.new(
        publication: @publication,
        name: draft_params[:name],
        path: @drafts_root_path.join(draft_params[:name]).to_s
      )

      if @commit.valid? && @commit.create_for!(blob: @draft)
        redirect_to publication_edit_draft_path(@publication, @draft)
      else
        respond_to do |format|
          format.html { publication_new_draft_path(@publication, @draft) }
          format.turbo_stream { render turbo_stream: turbo_stream.replace(@draft, partial: 'form', locals: { draft: @draft }) }
        end
      end
    end

    def update
      @commit = Git::Commit.new(
        author: Git::Author.for(user: Current.user),
        committer: Git::Committer.chuspace,
        message: draft_params[:commit_message],
        adapter: @publication.git_provider_adapter
      )

      if @commit.valid? && @commit.create_for!(blob: @draft)
        redirect_to publication_edit_draft_path(@publication, @draft), notice: 'Succesfully updated!'
      else
        respond_to do |format|
          format.html { publication_edit_draft_path(@publication, @draft) }
          format.turbo_stream { render turbo_stream: turbo_stream.replace(@draft, partial: 'edit_form', locals: { draft: @draft, publication: @publication }) }
        end
      end
    end

    def new
      @draft = Draft.new(publication: @publication, path: @drafts_root_path)
      add_breadcrumb(:drafts, publication_drafts_root_path(@publication))
      add_breadcrumb('New')
    end

    def show
      @path = @draft_path
    end

    def edit
      add_breadcrumb(:drafts, publication_drafts_root_path(@publication))
      add_breadcrumb(@draft.relative_path, publication_preview_draft_path(@publication, @draft))
      add_breadcrumb('Edit')
    end

    private

    def draft_params
      params.require(:draft).permit(:name, :commit_message)
    end

    def find_draft
      @draft = @publication.draft(path: @draft_path)
    end
  end
end
