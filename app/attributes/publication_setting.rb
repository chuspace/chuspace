# frozen_string_literal: true

class PublicationSetting
  include AttrJson::Model

  attr_json :auto_publish, :boolean, default: PublicationConfig.new.settings[:auto_publish]
  attr_json :extensions, :string, array: true, default: PublicationConfig.new.settings[:extensions]

  validates :extensions, presence: true
end
