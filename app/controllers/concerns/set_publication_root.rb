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
    @draft_path ||= @drafts_root_path.join(params[:path] || '').to_s
  end
end
