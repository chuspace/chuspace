# frozen_string_literal: true

class MarkdownValidator < ActiveModel::EachValidator
  VALID_MIME = 'text/markdown'.freeze

  def validate_each(record, attribute, value)
    unless MiniMime.lookup_by_filename(value).content_type == VALID_MIME
      record.errors.add attribute, (options[:message] || 'is not a valid markdown')
    end
  end
end
