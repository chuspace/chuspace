module Redirectable
  extend ActiveSupport::Concern

  REDIRECTABLE_FORMATS = ['*/*', :html]

  def redirect_location_for(key)
    session_key = redirect_location_key_for(key)

    if is_navigational_format?
      session.delete(session_key)
    else
      session[session_key]
    end
  end

  def store_location_for(key, location)
    session_key = redirect_location_key_for(key)

    path = extract_path_from_location(location)
    session[session_key] = path if path
  end

  def request_format
    @request_format ||= request.format.try(:ref)
  end

  def is_navigational_format?
    REDIRECTABLE_FORMATS.include?(request_format)
  end

  def is_flashing_format?
    request.respond_to?(:flash) && is_navigational_format?
  end

  private

  def parse_uri(location)
    location && URI.parse(location)
  rescue URI::InvalidURIError
    nil
  end

  def redirect_location_key_for(key)
    "#{key}_redirect_to"
  end

  def extract_path_from_location(location)
    uri = parse_uri(location)

    if uri
      path = remove_domain_from_uri(uri)
      path = add_fragment_back_to_path(uri, path)

      path
    end
  end

  def remove_domain_from_uri(uri)
    [uri.path.sub(/\A\/+/, '/'), uri.query].compact.join('?')
  end

  def add_fragment_back_to_path(uri, path)
    [path, uri.fragment].compact.join('#')
  end
end
