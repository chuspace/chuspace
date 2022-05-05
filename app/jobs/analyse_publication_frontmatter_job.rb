# frozen_string_literal: true

class AnalysePublicationFrontmatterJob < ApplicationJob
  def perform(publication:)
    publication.front_matter.keys = publication.repository.draft_files.each_with_object([]) do |file, keys|
      keys << publication.repository.draft(path: file.path)&.front_matter&.keys
    end.flatten.uniq

    publication.save!
  end
end
