# frozen_string_literal: true

module Git
  class Blob < ActiveType::Object
    extend ActiveModel::Callbacks

    attribute :id, :string
    attribute :path, :string
    attribute :name, :string
    attribute :type, :string, default: proc { :blob }
    attribute :content, :string, default: proc { '' }
    attribute :download_url, :string
    attribute :adapter, ApplicationAdapter

    validates :path, :name, :adapter, presence: true

    define_model_callbacks :create, :update, :destroy, only: :after

    def commits
      @commits ||= adapter.commits(path: path)
    end

    def create(content:, message: nil, author:)
      run_callbacks :create do
        fail ArgumentError, 'Not a valid author' unless author.is_a?(Git::Committer)
        fail TypeError, 'Can not be committed' unless is_a?(Draft) || is_a?(Asset)

        if valid?
          content  = Base64.encode64(content)
          response = adapter.create_blob(
            path: path,
            content: content,
            message: message,
            author: author
          )

          blob_attributes = response.content.to_h.slice(*Git::Blob.new.attributes.keys)
          self.assign_attributes(content: content, **blob_attributes)
        end

        self
      end
    end

    def decoded_content
      Base64.decode64(content).force_encoding('UTF-8')
    end

    def update(content:, message: nil, author:)
      run_callbacks :update do
        fail ArgumentError, 'Not a valid author' unless author.is_a?(Git::Committer)
        fail TypeError, 'Can not be committed' unless is_a?(Draft) || is_a?(Asset)
        fail ArgumentError, 'ID can not be blank' if id.blank?

        if valid?
          content  = Base64.encode64(content)
          response = adapter.update_blob(
            path: path,
            content: content,
            message: message,
            sha: id,
            author: author
          )

          blob_attributes = response.content.to_h.slice(*Git::Blob.new.attributes.keys)
          self.assign_attributes(content: content, **blob_attributes)
        end

        self
      end
    end

    def decorate(publication:)
      if MarkdownValidator.valid?(name_or_path: name)
        Draft.new(publication: publication, **attributes)
      elsif ImageValidator.valid?(name_or_path: name)
        Asset.new(publication: publication, **attributes)
      else
        self
      end
    end

    def delete(message: nil, author:)
      run_callbacks :destroy do
        fail ArgumentError, 'Not a valid author' unless author.is_a?(Git::Committer)
        fail TypeError, 'Can not be deleted' unless is_a?(Draft) || is_a?(Asset)

        adapter.delete_blob(
          path: path,
          id: sha,
          message: message,
          author: author
        )

        self
      end
    end

    def persisted?
      id.present?
    end

    def sha
      id
    end

    def to_param
      name
    end

    def self.valid?(name:)
      MarkdownValidator.valid?(name_or_path: name) || ImageValidator.valid?(name_or_path: name)
    end
  end
end
