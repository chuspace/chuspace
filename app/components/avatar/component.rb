# frozen_string_literal: true

module Avatar
  class Component < ApplicationComponent
    validates :variant, inclusion: { in: User::AVATAR_VARIANTS.keys, message: '%{value} is not a valid size' }
    attr_reader :avatar, :fallback, :variant

    def initialize(avatar:, fallback:, variant: :icon)
      @avatar   = avatar
      @fallback = fallback
      @variant  = variant
    end

    def class_name
      User::AVATAR_VARIANTS[variant][:classname]
    end
  end
end
