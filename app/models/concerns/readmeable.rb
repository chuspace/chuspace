module Readmeable
  extend ActiveSupport::Concern

  included do
    before_save :parse_and_store_readme, if: :readme_path_changed?
  end

  def parse_and_store_readme
    self.readme = repository.readme.content_html
  end
end
