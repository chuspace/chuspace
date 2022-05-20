# frozen_string_literal: true

class UserResource < ApplicationResource
  root_key :user
  attributes :name, :username, :avatar_url
end
