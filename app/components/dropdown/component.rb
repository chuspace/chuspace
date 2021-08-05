# frozen_string_literal: true

class Dropdown::Component < ApplicationComponent
  renders_one :header
  renders_one :body

  attr_reader :arrow, :css_classes

  def initialize(arrow: false, css_classes: '')
    @arrow = arrow
    @css_classes = css_classes
  end
end
