# frozen_string_literal: true

module Placeholder
  class Component < ApplicationComponent
    renders_one :cta
    renders_one :text
  end
end
