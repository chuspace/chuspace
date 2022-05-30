# frozen_string_literal: true

class RootConstraint
  def matches?(request)
    cookies = ActionDispatch::Cookies::CookieJar.build(request, request.cookies)
    Identity.fetch_by_id(cookies.encrypted[:identity_id]).present?
  end
end
