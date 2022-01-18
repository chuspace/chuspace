# frozen_string_literal: true

class MarkdownValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    unless MarkdownConfig.valid?(name: value)
      record.errors.add attribute, (options[:message] || "#{value} does not have a valid markdown file extension")
    end
  end
end
