# frozen_string_literal: true

module Header
  class Component < ApplicationComponent
    renders_one :after_logo_contents
    renders_one :before_user_dropdown
  end
end
