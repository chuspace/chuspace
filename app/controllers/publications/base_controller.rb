# frozen_string_literal: true

module Publications
  class BaseController < ApplicationController
    include Breadcrumbable, FindPublication
    prepend_before_action :authenticate!
  end
end
