# frozen_string_literal: true

module Publications
  class DraftsController < BaseController
    include SetPublicationRoot

    prepend_before_action :authenticate!
    before_action :build_draft, only: %i[index new create]
    before_action :find_draft, only: %w[update edit destroy]

    layout 'editor', only: %i[new edit]

    def index
      authorize! @draft
      @invite   = @publication.invites.build(sender: Current.user, role: Membership::DEFAULT_ROLE)
      published = params[:status] == 'published'

      published ? add_breadcrumb(:published) : add_breadcrumb(:drafts)

      if turbo_frame_request?
        @drafts = @publication.repository.drafts(path: @draft_path, published: published)
        render partial: 'list', locals: { drafts: @drafts, publication: @publication }
      end
    end

    def create
      authorize! @draft

      @draft.assign_attributes(name: draft_params[:name], path: @drafts_root_path.join(draft_params[:name]).to_s)

      if @draft.valid? && @draft.create(**commit_params)
        redirect_to publication_edit_draft_path(@publication, @draft)
      else
        respond_to do |format|
          format.html { publication_new_draft_path(@publication, @draft) }
          format.turbo_stream { render turbo_stream: turbo_stream.replace(@draft, partial: 'form', locals: { draft: @draft }) }
        end
      end
    end

    def destroy
      authorize! @draft

      if @draft.delete(**commit_params)
        redirect_to find_publication_drafts_root_path, notice: 'Successfully deleted'
      else
        redirect_to publication_edit_draft_path(@publication, @draft), notice: 'Something went wrong!'
      end
    end

    def update
      authorize! @draft, to: :commit?

      if @draft.update(**commit_params)
        @draft.reload!

        if @publication.content.auto_publish && @draft.publishable? && post = @draft.publish(author: Current.user)
          redirect_to publication_post_path(@publication, post), notice: 'Succesfully committed and published!'
        else
          redirect_to publication_edit_draft_path(@publication, @draft), notice: 'Succesfully committed!'
        end
      else
        respond_to do |format|
          format.html { publication_edit_draft_path(@publication, @draft) }
          format.turbo_stream { render turbo_stream: turbo_stream.replace(@draft, partial: 'edit_form', locals: { draft: @draft, publication: @publication }) }
        end
      end
    end

    def new
      authorize! @draft
      add_breadcrumb(:drafts, find_publication_drafts_root_path)
    end

    def edit
      authorize! @draft
      add_breadcrumb(:drafts, find_publication_drafts_root_path)
    end

    private

    def build_draft
      @drafts_root_path = @drafts_root_path.join(params[:path]) if params[:path].present?
      @draft = Draft.new(publication: @publication, content: '', adapter: @publication.repository.git_provider_adapter, path: @drafts_root_path)
    end

    def commit_params
      {
        content: @draft.persisted? ? @draft.local_or_remote_content : @draft.new_template,
        message: draft_params[:commit_message],
        author: Git::Committer.for(user: Current.user)
      }.freeze
    end

    def draft_params
      params.require(:draft).permit(:name, :content, :commit_message, :auto_publish)
    end

    def find_draft
      @draft = @publication.repository.draft(path: @draft_path)
    end
  end
end
