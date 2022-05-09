# frozen_string_literal: true

return unless Rails.env.development? || ENV.fetch('RUN_DB_SEED', 'no') == 'yes'

ActsAsTaggableOn::Tag.delete_all
topics = JSON.parse(Rails.root.join('db/topics.json').read)
ActsAsTaggableOn::Tag.insert_all(topics)
