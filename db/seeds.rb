# frozen_string_literal: true

return unless Rails.env.development? || ENV.fetch('RUN_DB_SEED', 'no') == 'yes'

publication = Publication.first
repository = publication.repository

tags = []

Language.all.each do |language|
  sleep 2.5
  puts "Seeding #{language.name}"
  puts "\n"
  repository.git_provider_adapter.topics(query: language.name).items.each do |item|
    tags << item.to_h.slice(*ActsAsTaggableOn::Tag.new.attributes.symbolize_keys.keys)
  end
end

File.open("db/topics.json","w") do |f|
  f.write(JSON.pretty_generate(tags))
end
