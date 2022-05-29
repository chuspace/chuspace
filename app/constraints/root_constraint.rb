# frozen_string_literal: true

class RootConstraint
  def matches?(request)
    cookies = ActionDispatch::Cookies::CookieJar.build(request, request.cookies)
    Identity.exists?(id: cookies.encrypted[:identity_id])
  end
end
