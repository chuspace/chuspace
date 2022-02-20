# frozen_string_literal: true

$meliasearch_client = MeiliSearch::Client.new(Rails.application.credentials.meilisearch[:host], Rails.application.credentials.meilisearch[:api_key])
