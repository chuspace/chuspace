# frozen_string_literal: true

module ApplicationHelper
  def link_class(path)
    default_class = 'link link--default'
    current_page?(path) ? default_class + ' link--active font-bold' : default_class
  end
end
