# frozen_string_literal: true

class Asset < Git::Blob
  attribute :publication, Publication
  validates :path, :name, image: true

  def all(paths = repository.assets_folders, options = { ref: repository.default_ref })
    super(paths, options)
  end
end
