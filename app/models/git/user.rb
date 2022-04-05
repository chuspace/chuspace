# frozen_string_literal: true

module Git
  class User < ActiveType::Object
    attribute :id, :integer
    attribute :avatar_url, :string
    attribute :username, :string
    attribute :name, :string
    attribute :email, :string
    attribute :date, :datetime

    validates :username, :name, :email, presence: true

    class << self
      def from_response(repository, response)
        case response
        when Array
          response.filter_map do |item|
            from_response(repository, item)
          end
        when Sawyer::Resource
          Git::User.new(
            id: response.id,
            name: response.name,
            type: response.type,
            username: response.login || response.username || response.full_path,
            avatar_url: response.avatar_url
          )
        else
          response
        end
      end
    end

    def git_attrs
      attributes.slice('name', 'email').merge(date: Date.today)
    end

    def self.for(user:)
      new(name: user.name, email: user.email, date: Date.today)
    end

    def self.from(hash)
      new(**hash.slice(*new.attributes.symbolize_keys.keys))
    end

    def self.chuspace
      new(GitConfig.new.committer)
    end
  end
end
