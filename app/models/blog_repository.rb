class BlogRepository
  include ActiveModel::Model
  attr_accessor :id, :name, :description, :visibility, :url
end
