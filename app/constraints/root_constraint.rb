# frozen_string_literal: true

class RootConstraint
  def matches?(request)
    Identity.fetch_by_id(request.session[:identity_id]).present?
  end
end
