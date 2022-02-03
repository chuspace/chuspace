# frozen_string_literal: true

module Publications
  class DraftsController < ApplicationController
    include Breadcrumbable, SetPublicationRoot
    before_action :find_draft, only: %w[update edit destroy]

    layout 'editor', only: %i[new edit]

    def create
      path = @drafts_root_path.join(create_params[:name] || '').to_s
      @draft = Draft.new(publication: @publication, path: path, **create_params)

      if @draft.valid? && @draft.commit!
        redirect_to publication_edit_draft_path(@publication, @draft)
      else
        respond_to do |format|
          format.html { publication_new_draft_path(@publication, @draft) }
          format.turbo_stream { render turbo_stream: turbo_stream.replace(@draft, partial: 'form', locals: { draft: @draft }) }
        end
      end
    end

    def update
      @draft.assign_attributes(update_params)

      if @draft.valid? && @draft.commit!
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

    def create_params
      params.require(:draft).permit(:name, :commit_message)
    end

    def update_params
      params.require(:draft).permit(:raw_content, :commit_message)
    end

    def find_draft
      @draft = @publication.git_repository.draft(path: @draft_path)
    end
  end
end
