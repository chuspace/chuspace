# frozen_string_literal: true

class UserFilter
  include Minidusen::Filter

  filter :text do |scope, phrases|
    columns = %i[first_name last_name username]
    scope.where_like(columns => phrases)
  end
end
