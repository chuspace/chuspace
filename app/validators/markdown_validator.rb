# frozen_string_literal: true

class MarkdownValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    unless Post.valid_mime?(name: value)
      record.errors.add attribute, (options[:message] || 'is not a valid markdown file')
    end
  end
end
