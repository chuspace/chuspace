# frozen_string_literal: true

class RootConstraint
  def matches?(request)
    Identity.exists?(id: request.session[:identity_id])
  end
end
