# frozen_string_literal: true

class ImageValidator < ActiveModel::EachValidator
  VALID_MIMES = %w[image/jpeg image/png image/jpg image/gif]

  def self.valid?(name_or_path:)
    VALID_MIMES.include?(MiniMime.lookup_by_filename(name_or_path)&.content_type)
  end

  def validate_each(record, attribute, value)
    unless ImageValidator.valid?(name_or_path: value)
      record.errors.add attribute, (options[:message] || "#{value} does not have a valid markdown file extension")
    end
  end
end
