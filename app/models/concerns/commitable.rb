module Commitable
  extend ActiveSupport::Concern

  def git_commits(path: '.')
    storage.adapter.commits(fullname: repo_fullname, path: path)
  end

  def git_commit(action: :create, path:, content:, message:)
    case action.to_sym
    when :create
      storage.adapter.create_blob(fullname: repo_fullname, path: path, content: content, message: message)
    when :update
      storage.adapter.update_blob(fullname: repo_fullname, path: path, content: content, message: message)
    when :delete
      storage.adapter.delete_blob(fullname: repo_fullname, path: path, id: id, message: message)
    end
  end
end
