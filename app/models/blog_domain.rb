class BlogDomain
  include ActiveModel::Model
  attr_accessor :domain, :auto_ssl_enabled, :certificate, :key
end
