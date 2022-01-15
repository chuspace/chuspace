# frozen_string_literal: true

class GraphqlAdapter
  class QueryNotFoundError < StandardError; end
  class ClientNotFoundError < StandardError; end
  class RepoNotSetError < StandardError; end

  attr_reader :git_provider, :client, :repo_owner, :repo_name

  def initialize(git_provider:)
    @git_provider = git_provider
    @client = Chuspace::Application.config.graphql_client.send(@git_provider.name)
    fail ClientNotFoundError, "#{@git_provider.name} client not found" if client.nil?
  end

  def apply_repository_scope(repo_fullname:)
    @repo_owner, @repo_name = repo_fullname.split('/')
  end

  def blob(expression: 'HEAD:README.md')
    branch, path = expression.split(':')

    client.query(
      query_document(name: :blob),
      variables: { expression: expression, **repo_variables },
      context: context
    ).data.repository.blob
  end

  alias readme blob

  def blobs(expression: 'HEAD:')
    client.query(
      query_document(name: :blobs),
      variables: { expression: expression, **repo_variables },
      context: context
    ).data.repository.tree.blobs.sort_by { |blob| blobs_order.index(blob.type) || 99 }
  end

  def repository
    client.query(
      query_document(name: :repository),
      variables: repo_variables,
      context: context
    ).data.repository
  end

  private

  def blobs_order
    %w[tree dir blob file]
  end

  def query_document(name:)
    client.parse("Queries::#{git_provider.name.camelize}::#{name.to_s.camelize}Query".constantize)
  end

  def context
    { access_token: git_provider.access_token }.freeze
  end

  def repo_variables
    fail RepoNotSetError 'Repo not set' if repo_owner.nil?

    { owner: repo_owner, name: repo_name }.freeze
  end
end
