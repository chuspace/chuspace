MeiliSearch.configuration = {
  meilisearch_host: Rails.application.credentials.meilisearch[:host],
  meilisearch_api_key: Rails.application.credentials.meilisearch[:api_key],
}
