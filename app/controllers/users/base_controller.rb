# frozen_string_literal: true

module Users
  class BaseController < ApplicationController
    layout 'user'

    include Breadcrumbable, FindUser
    prepend_before_action :authenticate!
  end
end
