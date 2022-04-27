# frozen_string_literal: true

class UserResource < ApplicationResource
  key :user
  attributes :name, :username, :avatar_url
end
