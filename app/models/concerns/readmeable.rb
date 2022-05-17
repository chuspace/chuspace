# frozen_string_literal: true

module Readmeable
  extend ActiveSupport::Concern

  included do
    validates :readme_path, markdown: true
    before_save :parse_and_store_readme, if: -> { readme_path && (readme.blank? || readme_path_changed?) }
  end

  def readme_draft(ref: default_ref)
    draft_at(path: readme_path, ref: ref)
  end

  private

  def parse_and_store_readme
    self.readme = readme_draft.content_html
  end
end
