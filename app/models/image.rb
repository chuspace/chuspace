# frozen_string_literal: true

require 'down/http'

class Image < ApplicationRecord
  belongs_to :publication

  validates :name, :draft_blob_path, presence: true
  validates :blob_path, presence: true, uniqueness: { scope: :publication_id }

  delegate :repository, to: :publication

  after_create :attach_image

  has_one_attached :image do |attachable|
    attachable.variant :post, resize_to_fit: [800, 300]
    attachable.variant :list, resize_to_fit: [250, 150]
    attachable.variant :icon, resize_to_fit: [64, 64]
    attachable.variant :social, resize_to_fit: [600, 315]
  end

  def io
    external? ? Down::Http.open(blob_path) : StringIO.new(repository.raw(path: blob_path))
  end

  private

  def attach_image
    image.attach(io: io, filename: name)
  end
end
