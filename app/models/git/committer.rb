# frozen_string_literal: true

module Git
  class Committer < ActiveType::Object
    attribute :id, :integer
    attribute :avatar_url, :string
    attribute :username, :string
    attribute :name, :string
    attribute :email, :string
    attribute :date, :datetime

    validates :username, :name, :email, presence: true

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
