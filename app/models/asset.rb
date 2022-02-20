# frozen_string_literal: true

class Asset < Git::Blob
  attribute :publication, Publication
  validates :path, :name, image: true
end
