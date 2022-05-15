class RedirectUrl
  attr_reader :path, :params

  def initialize(path:, params:)
    @path    = path
    @params  = params
  end

  def for(record, only_path: true)
    model     = record.class.name.downcase
    attribute = permalink_attribute[model.to_sym]
    permalink = params[:"#{model}_#{attribute}"] || params[:"#{attribute}"]
    route     = Rails.application.routes.recognize_path(path)

    route[:"#{model}_#{attribute}"] = record.send(attribute) if route.key?(:"#{model}_#{attribute}")
    route[:"#{attribute}"] = record.send(attribute) if route.key?(:"#{attribute}")

    Rails.application.routes.url_helpers.url_for(**route.merge(only_path: only_path))
  end

  private

  def permalink_attribute
    {
      publication: :permalink,
      user: :username,
      post: :permalink
    }.freeze
  end
end
