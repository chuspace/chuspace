# frozen_string_literal: true

module Users
  class BaseController < ApplicationController
    layout 'user'

    include Breadcrumbable, FindUser
  end
end
