# frozen_string_literal: true

class PublicationContentSetting
  include AttrJson::Model

  attr_json :auto_publish, :boolean, default: PublicationConfig.new.settings[:auto_publish]
end
