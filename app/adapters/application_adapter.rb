# frozen_string_literal: true

class ApplicationAdapter
  include FaradayClient::Connection
  attr_reader :endpoint, :access_token

  def initialize(endpoint:, access_token:)
    @endpoint = endpoint
    @access_token = access_token
  end

  def scopes
    GitStorageConfig.new.send(name)[:scopes]
  end

  private

  def decorate_repository(object)
    case object
    when nil then BlogRepository.new
    when Array then object.map { |item| decorate_repository(item) }
    else
      case name.to_sym
      when :github
        BlogRepository.new(
          id: object.id,
          name: object.full_name.squish,
          description: object.description,
          visibility: object.private ? :private : :public,
          url: object.html_url
        )
      when :chuspace, :gitlab
        BlogRepository.new(
          id: object.id,
          name: object.path_with_namespace.squish,
          description: object.description,
          visibility: object.visibility,
          url: object.web_url
        )
      end
    end
  end
end
