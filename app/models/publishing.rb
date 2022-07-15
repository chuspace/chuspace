# frozen_string_literal: true

class Publishing < ApplicationRecord
  include Drafts::Yaml
  include Drafts::FrontMatter

  belongs_to :post
  belongs_to :author, class_name: 'User'

  delegate :publication, to: :post

  validates :commit_sha, presence: true

  after_create_commit :reset_current

  scope :recent, -> { order(id: :desc) }

  def short_commit_sha
    commit_sha.first(7)
  end

  def decoded_content
    content
  end

  def body_html
    PublicationHtmlRenderer.new(publication: publication).render(markdown_doc.doc)
  end

  def markdown_doc
    MarkdownDoc.new(content: parsed.content)
  end

  def to_param
    version
  end

  private

  def reset_current
    post.publishings.where.not(id: id).update_all(current: false)
  end
end
