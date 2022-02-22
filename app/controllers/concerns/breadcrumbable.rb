# frozen_string_literal: true

module Breadcrumbable
  extend ActiveSupport::Concern

  included do
    helper_method :breadcrumbs
  end

  def breadcrumbs
    @breadcrumbs ||= []
  end

  def add_breadcrumb(name, path = nil)
    breadcrumbs << Breadcrumb.new(name: name, path: path)
  end
end
