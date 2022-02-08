# frozen_string_literal: true

module Git
  class Blob < ActiveType::Object
    attribute :id, :string
    attribute :path, :string
    attribute :name, :string
    attribute :type, :string, default: proc { :blob }
    attribute :content, :string, default: proc { '' }
    attribute :adapter, ApplicationAdapter

    validates :path, :name, :content, :adapter, presence: true

    def to_draft(publication:)
      if MarkdownConfig.valid?(name: name)
        Draft.new(publication: publication, **attributes)
      else
        self
      end
    end

    def commits
      @commits ||= adapter.commits(path: path)
    end

    def persisted?
      id.present?
    end

    def to_param
      name
    end
  end
end
