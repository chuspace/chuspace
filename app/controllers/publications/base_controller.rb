# frozen_string_literal: true

module Publications
  class BaseController < ApplicationController
    include Breadcrumbable, FindPublication
    before_action :authenticate!
  end
end
