# frozen_string_literal: true


class BlogFrameworkConfig < ApplicationConfig
  attr_config(frameworks: JSON.parse(Rails.root.join('db/defaults/templates.json').read))

  def self.default
    defaults['frameworks'].find do |value|
      value['default']
    end
  end
end
