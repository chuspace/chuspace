# frozen_string_literal: true

class UserConstraint
  def matches?(request)
    username = request.params[:username] || request.params[:user_username]
    User.friendly_fetch(username).present?
  end
end
