# frozen_string_literal: true

namespace :graphql do
  namespace :schema do
    task :dump do
      GraphQL::Client.dump_schema(Chuspace::GithubGraphqlAdapter, 'db/schema.json')
    end
  end
end
