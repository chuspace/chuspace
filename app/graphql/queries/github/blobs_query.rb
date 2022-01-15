# frozen_string_literal: true

Queries::Github::BlobsQuery = <<-GRAPHQL
  query($owner: String!, $name: String!, $expression: String = "HEAD:") {
    repository(owner: $owner, name: $name) {
      tree: object(expression: $expression) {
        ... on Tree {
          blobs: entries {
            id: oid
            path
            name
            type
            extension

            blob: object {
              ... on Blob {
                id: oid
                content: text
                is_binary: isBinary
              }
            }
          }
        }
      }
    }
  }
GRAPHQL
