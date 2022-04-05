# frozen_string_literal: true

module Git
  class Repository < ActiveType::Object
    attribute :id, :string
    attribute :fullname, :string
    attribute :name, :string
    attribute :owner, :string
    attribute :description, :string
    attribute :visibility, :string
    attribute :ssh_url, :string
    attribute :html_url, :string
    attribute :default_branch, :string
    attribute :repository, Repository

    class << self
      def for(repository)
        from_response(repository.api.get(repository.endpoint))
      end

      def from_response(repository, response)
        case response
        when Array
          response.filter_map do |item|
            from_response(repository, item)
          end
        when Sawyer::Resource
          Git::Repository.new(
            id: response.id,
            fullname: response.full_name&.squish || response.path_with_namespace&.squish,
            name: response.name,
            owner: response.namespace&.path || response.owner&.login,
            description: response.description,
            visibility: response.visibility || response.owner&.visibility,
            ssh_url: response.ssh_url_to_repo || response.ssh_url,
            html_url: response.web_url || response.html_url,
            default_branch: response.default_branch,
            repository: repository
          )
        else
          response
        end
      end
    end
  end
end
