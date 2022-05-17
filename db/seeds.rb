# frozen_string_literal: true

return unless Rails.env.development? || ENV.fetch('RUN_DB_SEED', 'no') == 'yes'

ActsAsTaggableOn::Tag.delete_all
topics = JSON.parse(Rails.root.join('db/topics.json').read)
ActsAsTaggableOn::Tag.insert_all(topics.map { |topic| topic.except('icon') })

require 'down/http'

topics.select { |topic| topic.dig('icon').present? }.each do |topic|
  tag = ActsAsTaggableOn::Tag.find_by(name: topic['name'])
  tag.icon.attach(io: Down::Http.open(topic['icon']), filename: File.basename(topic['icon']))
end
