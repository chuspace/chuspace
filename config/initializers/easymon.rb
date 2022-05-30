# frozen_string_literal: true

if Rails.env.production?
  Easymon::Repository.add(
    'application-database',
    Easymon::ActiveRecordCheck.new(ActiveRecord::Base),
    :critical
  )
end
