
class RootConstraint
  def matches?(request)
    cookies = ActionDispatch::Cookies::CookieJar.build(request, request.cookies)
    Identity.find_by(id: cookies.encrypted[:identity_id])
  end
end
