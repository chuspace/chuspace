# frozen_string_literal: true

Queries::Github::BlobQuery = <<-GRAPHQL
  query($owner: String!, $name: String!, $expression: String = "HEAD:") {
    repository(owner: $owner, name: $name) {
      blob: object(expression: $expression) {
        ... on Blob {
          id: oid
          content: text
          is_binary: isBinary
        }
      }
    }
  }
GRAPHQL
