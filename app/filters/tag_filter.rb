# frozen_string_literal: true

class TagFilter
  include Minidusen::Filter

  filter :text do |scope, phrases|
    columns = %i[name description short_description]
    scope.where_like(columns => phrases)
  end
end
