# frozen_string_literal: true

class DraftSetting
  include AttrJson::Model

  attr_json :auto_publish, :boolean, default: PublicationConfig.new.draft[:auto_publish]
  attr_json :extensions, :string, array: true, default: PublicationConfig.new.draft[:extensions]

  validates :extensions, presence: true
end
