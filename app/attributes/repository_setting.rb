# frozen_string_literal: true

class RepositorySetting
  include AttrJson::Model

  attr_json :fullname, :string
  attr_json :webhook_id, :integer
  attr_json :posts_folder, :string
  attr_json :drafts_folder, :string
  attr_json :assets_folder, :string
  attr_json :readme_path, :string, default: PublicationConfig.new.repo[:readme_path]

  validates :fullname, :posts_folder, :assets_folder, :readme_path, presence: true
end
