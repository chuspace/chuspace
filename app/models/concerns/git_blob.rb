module GitBlob
  extend ActiveSupport::Concern

  def base64_blob_content
    content = if raw_content.respond_to?(:attachment)
      raw_content.attachment.blob.download
    else
      raw_content.to_plain_text
    end

    Base64.strict_encode64(content)
  end

  def git_commits
    blog.storage.adapter.commits(fullname: blog_repo_fullname, path: path)
  end

  def git_commit(action: :create)
    case action.to_sym
    when :create
      storage.adapter.create_blob(fullname: blog_repo_fullname, path: path, content: base64_blob_content, message: nil)
    when :update
      storage.adapter.update_blob(fullname: blog_repo_fullname, path: path, content: base64_blob_content, message: nil)
    when :delete
      storage.adapter.delete_blob(fullname: blog_repo_fullname, path: path, id: id)
    end
  end
end
