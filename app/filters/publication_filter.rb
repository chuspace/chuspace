# frozen_string_literal: true

class PublicationFilter
  include Minidusen::Filter

  filter :text do |scope, phrases|
    columns = %i[name description]
    scope.where_like(columns => phrases)
  end
end
