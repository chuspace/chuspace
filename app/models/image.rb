# frozen_string_literal: true

class Image < ApplicationRecord
  belongs_to :publication

  validates :name, :draft_blob_path, presence: true
  validates :blob_path, presence: true, uniqueness: { scope: :publication_id }

  delegate :repository, to: :publication

  after_create :attach_image

  has_one_attached :image do |attachable|
    attachable.variant :post, resize_to_fit: [1600, 600]
    attachable.variant :list, resize_to_fit: [500, 300]
    attachable.variant :social, resize_to_fit: [1200, 630]
  end

  def cdn_image_url(variant: :post)
    if image.attached?
      if image.variable?
        Rails.application.routes.url_helpers.rails_public_blob_url(image.variant(variant))
      else
        Rails.application.routes.url_helpers.rails_public_blob_url(image)
      end
    end
  end

  private

  def attach_image
    image.attach(io: StringIO.new(repository.raw(path: blob_path)), filename: name)
  end
end
