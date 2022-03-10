# frozen_string_literal: true

module Card
  class Component < ApplicationComponent
    renders_one :title
    renders_one :actions
    renders_one :body
  end
end
