# frozen_string_literal: true

module SetPublicationRoot
  extend ActiveSupport::Concern

  included do
    before_action :set_drafts_root_path, :set_draft_path
  end

  def set_drafts_root_path
    @drafts_root_path = Pathname.new(@publication.repository.drafts_or_posts_folder)
  end

  def set_draft_path
    @path = params[:path] || ''
    @draft_path ||= @path == @publication.repository.readme_path ? @path : @drafts_root_path.join(@path).to_s
  end

  def find_publication_drafts_root_path
    if @publication.personal?
      user_tab_path(@publication.owner, id: :drafts)
    else
      publication_drafts_root_path(@publication)
    end
  end
end
