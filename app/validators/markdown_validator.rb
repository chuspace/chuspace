# frozen_string_literal: true

class MarkdownValidator < ActiveModel::EachValidator
  def self.valid?(name_or_path:)
    MiniMime.lookup_by_filename(name_or_path)&.content_type == 'text/markdown' if name_or_path
  end

  def validate_each(record, attribute, value)
    unless MarkdownValidator.valid?(name_or_path: value)
      record.errors.add attribute, (options[:message] || "#{value} does not have a valid markdown file extension")
    end
  end
end
