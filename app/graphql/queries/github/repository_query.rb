# frozen_string_literal: true

Queries::Github::RepositoryQuery = <<-GRAPHQL
  query($owner: String!, $name: String!) {
    repository(owner: $owner, name: $name) {
      id
      name
      description
      visibility

      default_branch: defaultBranchRef {
        name
      }

      owner {
        login
      }

      ssh_url: sshUrl
      url
    }
  }
GRAPHQL
