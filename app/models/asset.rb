# frozen_string_literal: true

class Asset < Git::Blob
  attribute :publication, Publication
  validates :path, :name, image: true

  after_create :touch_publication
  after_update :touch_publication

  private

  def touch_publication
    Publication.where(id: publication.id).touch_all
  end
end
