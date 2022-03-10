# frozen_string_literal: true

class UserTabConstraint
  def matches?(request)
    UserTab::PAGES.include?(request.params[:id])
  end
end
