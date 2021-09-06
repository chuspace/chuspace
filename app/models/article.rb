class Article
  include ActiveModel::Model
  attr_accessor :id, :filename, :title, :intro, :date, :tags, :published, :visibility, :content, :path

  def initialize(attributes = {})
    super

    @published ||= false
    @visibility ||= 'private'
    @tags ||= []
  end

  def self.from(response)
    case response
    when Array then response.map { |blob| Article.from(blob) }
    else
      content = Base64.decode64(response.content).force_encoding('UTF-8')
      parsed = FrontMatterParser::Parser.new(:md).call(content)

      Article.new(
        id: response.sha,
        filename: response.name,
        title: parsed.front_matter.dig('title') || parsed.content.first(80),
        intro: parsed.front_matter.dig('description'),
        date: parsed.front_matter.dig('date'),
        published: parsed.front_matter.dig('published'),
        visibility: parsed.front_matter.dig('visibility'),
        tags: parsed.front_matter.dig('tags'),
        path: response.path,
        content: parsed.content
      )
    end
  end

  def to_param
    id
  end
end
