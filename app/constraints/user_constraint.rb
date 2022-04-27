# frozen_string_literal: true

class UserConstraint
  def matches?(request)
    request.params[:username].present? || request.params[:user_username].present?
  end
end
