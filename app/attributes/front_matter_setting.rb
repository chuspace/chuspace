# frozen_string_literal: true

class FrontMatterSetting
  include AttrJson::Model

  attr_json :title, :string, default: PublicationConfig.new.front_matter[:title]
  attr_json :summary, :string, default: PublicationConfig.new.front_matter[:summary]
  attr_json :topics, :string, default: PublicationConfig.new.front_matter[:topics]
  attr_json :date, :string, default: PublicationConfig.new.front_matter[:date]
  attr_json :published, :string, default: PublicationConfig.new.front_matter[:published]
  attr_json :keys, :string, array: true, default: PublicationConfig.new.front_matter[:keys]

  validates :title, :summary, :topics, :date, :published, :keys, presence: true
end
