# frozen_string_literal: true

class RevisionResource < ApplicationResource
  key :revision
  attributes :id, :content_before, :status, :identifier, :content_after, :pos_from, :pos_to, :ydoc_base64, :widget_pos, :node
  one :author, resource: UserResource
  transform_keys :lower_camel

  attribute :path do |resource|
    url_helpers.publication_post_revision_path(resource.publication, resource.post, resource)
  end
end
