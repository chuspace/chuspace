# frozen_string_literal: true

module Avatar
  class Component < ApplicationComponent
    CLASSNAMES = {
      icon: {
        classname: 'w-8 h-8 rounded-full'
      },
      mini: {
        classname: 'w-16 h-16 rounded-full text-xl'
      },
      thumb: {
        classname: 'w-24 h-24 rounded-full text-3xl'
      },
      profile: {
        classname: 'w-32 h-32 rounded-full text-4xl'
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
