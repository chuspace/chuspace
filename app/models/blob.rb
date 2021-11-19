# frozen_string_literal: true

class Blob < ApplicationRecord
  MIMES = %w[text/markdown image/jpg image/jpeg image/png image/bmp image/avif image/gif].freeze
  COMMIT_ACTIONS = %i[create update delete].freeze
  belongs_to :repository
  delegate :blog, :storage, :user, to: :repository
  has_one_attached :content

  def commits
    storage.adapter.commits(fullname: repository.name, path: path)
  end

  def commit(message: nil, action: :create)
    action = action.to_sym
    message = "#{action.to_s.humanize} #{path}"
    fail ArgumentError, "Invalid action #{action}" unless COMMIT_ACTIONS.include?(action)

    case action
    when :create
      storage.adapter.create_blob(fullname: repo_fullname, path: path, content: base64_blob_content, message: message)
    when :update
      storage.adapter.update_blob(fullname: repo_fullname, path: path, content: base64_blob_content, message: message)
    when :delete
      storage.adapter.delete_blob(fullname: repo_fullname, path: path, id: id, message: message)
    end
  end

  def base64_blob_content
    Base64.strict_encode64(content)
  end
end
