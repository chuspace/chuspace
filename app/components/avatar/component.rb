# frozen_string_literal: true

module Avatar
  class Component < ApplicationComponent
    CLASSNAMES = {
      icon: {
        classname: 'w-8 rounded-full'
      },
      thumb: {
        classname: 'w-16 rounded-full'
      },
      profile: {
        classname: 'w-32 rounded-full'
      }
    }

    validates :variant, inclusion: { in: CLASSNAMES.keys, message: '%{value} is not a valid size' }
    attr_reader :avatar, :fallback, :gravatar, :variant, :uploader

    def initialize(avatar:, fallback:, gravatar: nil, variant: :icon, uploader: false)
      @avatar   = avatar
      @gravatar = gravatar
      @fallback = fallback
      @variant  = variant
      @uploader = uploader
    end

    def class_name
      CLASSNAMES[variant][:classname]
    end
  end
end
