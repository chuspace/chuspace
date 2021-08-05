# frozen_string_literal: true

class Avatar::Component < ApplicationComponent
  DEFAULT_CSS_CLASS = 'avatar lazy blur-up'

  def initialize(url:, css_class: '', variant: :xs, options: {})
    @url = url
    @css_class = css_class
    @variant = variant
    @options = options
  end

  def size
    VARIANTS[variant][:size]
  end

  def css_classes
    classes = [DEFAULT_CSS_CLASS]
    classes << "avatar--#{@variant}"
    classes << @css_class if @css_class
    classes.join(' ')
  end

  def call
    image_tag(@url, class: css_classes, alt: 'Avatar image', 'data-sizes': 'auto', **@options)
  end
end
