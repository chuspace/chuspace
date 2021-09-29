# frozen_string_literal: true

class Avatar::Component < ApplicationComponent
  def initialize(url:, css_class: '')
    @url = url
    @css_class = css_class
  end

  def call
    image_tag(@url, class: "avatar lazy blur-up #{@css_class}".squish, alt: 'Avatar image', 'data-sizes': 'auto')
  end
end
