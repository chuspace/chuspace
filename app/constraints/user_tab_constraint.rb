# frozen_string_literal: true

class UserTabConstraint
  def matches?(request)
    request.params[:user_username].present? && UserTab::PAGES.include?(request.params[:id])
  end
end
