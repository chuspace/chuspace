module SetPublicationRoot
  extend ActiveSupport::Concern

  included do
    before_action :find_publication, :set_drafts_root_path, :set_draft_path
  end

  def find_publication
    @publication = Publication.friendly.find(params[:publication_permalink])
    add_breadcrumb(@publication.permalink, publication_path(@publication))
  end

  def set_drafts_root_path
    @drafts_root_path = Pathname.new(@publication.repo.posts_folder)
  end

  def set_draft_path
    @path = params[:path] || ''
    @draft_path ||= @drafts_root_path.join(@path).to_s
  end

  def find_publication_drafts_root_path
    if @publication.personal?
      user_path(@publication.owner, tab: :drafts)
    else
      publication_drafts_root_path(@publication)
    end
  end
end
