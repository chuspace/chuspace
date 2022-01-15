# frozen_string_literal: true

class PostSetting
  include AttrJson::Model

  attr_json :auto_publish, :boolean, default: PublicationConfig.new.post[:auto_publish]
  attr_json :extensions, :string, array: true, default: PublicationConfig.new.post[:extensions]

  validates :extensions, presence: true
end
