# frozen_string_literal: true

module Users
  class PostsController < BaseController
    skip_verify_authorized

    def index
      add_breadcrumb(:Posts)
      @posts = @user.posts
    end
  end
end
