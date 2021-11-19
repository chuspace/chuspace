class Commit < ApplicationRecord
  belongs_to :blob
  delegate :repository, :storage, to: :blob

  def git_commit
    storage.adapter.commit(fullname: repository.name, sha: sha)
  end

  private

  def create_git_commit(commit_message: message, action: :create)
    action = action.to_sym
    commit_message = "#{action.to_s.humanize} #{path}"
    fail ArgumentError, "Invalid action #{action}" unless COMMIT_ACTIONS.include?(action)

    case action
    when :create
      storage.adapter.create_blob(fullname: repository.name, path: blob.path, content: blob.base64_blob_content, message: commit_message)
    when :update
      storage.adapter.update_blob(fullname: repository.name, path: blob.path, content: blob.base64_blob_content, message: commit_message)
    when :delete
      storage.adapter.delete_blob(fullname: repository.name, path: blob.path, id: id, message: commit_message)
    end
  end
end
