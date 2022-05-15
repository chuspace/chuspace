# frozen_string_literal: true

class RedirectUrl
  attr_reader :path, :params

  def initialize(path:, params:)
    @path    = path
    @params  = params
  end

  def for(record, only_path: true)
    model     = record.class.name.downcase
    attribute = record.friendly_id_config.slug_column
    permalink = params[:"#{model}_#{attribute}"] || params[:"#{attribute}"]
    route     = Rails.application.routes.recognize_path(path)

    if route.key?(:"#{model}_#{attribute}")
      route[:"#{model}_#{attribute}"] = record.send(attribute)
    elsif route.key?(:"#{attribute}")
      route[:"#{attribute}"] = record.send(attribute)
    end

    Rails.application.routes.url_helpers.url_for(**route.merge(only_path: only_path))
  end
end
