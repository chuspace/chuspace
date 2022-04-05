# frozen_string_literal: true

module Publications
  class DraftsController < BaseController
    include SetPublicationRoot

    prepend_before_action :authenticate!
    before_action :build_draft, only: %i[index new create]
    before_action :find_draft, only: %w[update ydoc edit destroy]

    layout 'editor', only: %i[new edit]

    def index
      authorize! @draft
      @invite = @publication.invites.build(sender: Current.user, role: Membership::DEFAULT_ROLE)
      add_breadcrumb(:drafts)

      if turbo_frame_request?
        @drafts = @publication.repository.drafts(path: @draft_path)
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
        @draft.end_collaboration_session
        redirect_to find_publication_drafts_root_path, notice: 'Successfully deleted'
      else
        redirect_to publication_edit_draft_path(@publication, @draft), notice: 'Something went wrong!'
      end
    end

    def update
      authorize! @draft, to: :commit?

      if @draft.update(**commit_params)
        @draft.publish(author: Current.user) if draft_params[:auto_publish].present?
        @draft.end_collaboration_session
        redirect_to publication_edit_draft_path(@publication, @draft), notice: 'Succesfully updated!'
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
      add_breadcrumb('New')
    end

    def edit
      authorize! @draft

      @collaboration_session = @publication.find_or_start_collaboration_session(user: Current.user, blob_path: @draft.path)

      add_breadcrumb(:drafts, find_publication_drafts_root_path)
      add_breadcrumb(@draft.relative_path, publication_preview_draft_path(@publication, @draft))
      add_breadcrumb('Edit')
    end

    private

    def build_draft
      @draft = Draft.new(publication: @publication, content: '', adapter: @publication.repository.git_provider_adapter, path: @drafts_root_path)
    end

    def commit_params
      {
        content: @draft.decoded_collaboration_session_content || '# foo',
        message: draft_params[:commit_message],
        committer: Git::Committer.chuspace,
        author: Git::Committer.for(user: Current.user)
      }.freeze
    end

    def draft_params
      params.require(:draft).permit(:name, :commit_message, :auto_publish)
    end

    def find_draft
      @draft = @publication.repository.draft(path: @draft_path)
    end
  end
end
