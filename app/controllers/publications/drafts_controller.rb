# frozen_string_literal: true

module Publications
  class DraftsController < ApplicationController
    include Breadcrumbable

    before_action :find_publication
    before_action :find_draft, only: %w[update edit destroy]

    layout 'editor', only: %i[new edit]

    def create
      path = File.join(@publication.repo_drafts_or_posts_folder, create_params[:name])
      @draft = Draft.new(publication: @publication, path: path, **create_params)

      if @draft.valid? && @draft.commit!
        redirect_to publication_edit_draft_path(@publication, @draft)
      else
        respond_to do |format|
          format.html { render :new }
          format.turbo_stream { render turbo_stream: turbo_stream.replace(@draft, partial: 'form', locals: { draft: @draft }) }
        end
      end
    end

    def update
      @draft.commit_message = update_params[:commit_message]
      new_content = @draft.to_raw_content(
        title: update_params[:title],
        summary: update_params[:summary],
        body: update_params[:body]
      )

      @draft.raw_content = new_content

      if @draft.valid? && @draft.commit!
        redirect_to publication_edit_draft_path(@publication, @draft)
      else
        respond_to do |format|
          format.html { render :new }
          format.turbo_stream { render turbo_stream: turbo_stream.replace(@draft, partial: 'form', locals: { draft: @draft }) }
        end
      end
    end

    def new
      @draft = Draft.new(publication: @publication, path: @publication.repo_drafts_or_posts_folder)
      add_breadcrumb(@publication.repo_drafts_or_posts_folder, publication_drafts_path(@publication, path: @publication.repo_drafts_or_posts_folder))
      add_breadcrumb('New')
    end

    def show
      @path = params[:path]
    end

    def edit
      add_breadcrumb(@publication.repo_drafts_or_posts_folder, publication_drafts_path(@publication, path: @publication.repo_drafts_or_posts_folder))
      add_breadcrumb(@draft.name, publication_preview_draft_path(@publication, @draft))
      add_breadcrumb('Edit')
    end

    private

    def create_params
      params.require(:draft).permit(:name, :commit_message)
    end

    def update_params
      params.require(:draft).permit(:title, :summary, :body, :commit_message)
    end

    def find_draft
      @draft = @publication.git_repository.draft(path: params[:path])
    end

    def find_publication
      @publication = Publication.friendly.find(params[:publication_permalink])
      add_breadcrumb(@publication.permalink, publication_path(@publication))
    end
  end
end
