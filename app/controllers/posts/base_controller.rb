# frozen_string_literal: true

module Posts
  class BaseController < ApplicationController
    before_action :authenticate!
    include Breadcrumbable
    include FindPublication
    include FindPost
  end
end
