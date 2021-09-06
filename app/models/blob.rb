class Blob
  include ActiveModel::Model
  attr_accessor :id, :title, :content, :path

  def to_param
    id
  end
end
