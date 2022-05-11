# frozen_string_literal: true

module Iconable
  extend ActiveSupport::Concern

  ICON_VARIANTS = {
    icon: 32,
    thumb: 100,
    profile: 250
  }

  included do
    has_one_attached :icon do |attachable|
      ICON_VARIANTS.each do |name, size|
        attachable.variant name, resize_to_fill: [size, size]
      end
    end
  end
end
