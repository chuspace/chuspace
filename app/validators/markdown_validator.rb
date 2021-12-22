# frozen_string_literal: true

class MarkdownValidator < ActiveModel::EachValidator
  VALID_MIME = 'text/markdown'.freeze

  def validate_each(record, attribute, value)
    unless Marcel::MimeType.for(name: value) == VALID_MIME
      record.errors.add attribute, (options[:message] || 'is not a valid markdown file')
    end
  end
end
