# frozen_string_literal: true

module Users
  class PostsController < BaseController
    def index
      authorize! Current.user, to: :show?
      add_breadcrumb(:Posts)
      @posts = authorized_scope(Post.all, type: :relation, as: :author)
    end
  end
end
