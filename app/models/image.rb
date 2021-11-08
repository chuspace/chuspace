class Image < ApplicationRecord
  belongs_to :blog
  has_one_attached :image

  validates :blob_path, uniqueness: { scope: :blog_id }
  validates :blob_path, :base64_blob_path, :blog_id, presence: true
  delegate :storage, :repo_fullname, to: :blog

  def self.create_from_blob_path(blog:, blob_path:)
    extension = File.extname(blob_path)
    mime = Marcel::MimeType.for extension: extension
    base64_blob_path = Base64.strict_encode64(blob_path) + extension

    io = if ApplicationController.helpers.url_or_mailto?(blob_path)
      Down::Http.download(blob_path)
    else
      blob_path = blob_path.start_with?('/') ? blob_path : "/#{blob_path}"
      StringIO.new(Base64.decode64(blog.git_blob(path: blob_path)&.content))
    end

    image = blog.images.build(blob_path: blob_path, base64_blob_path: base64_blob_path)
    image.image.attach(io: io, filename: base64_blob_path, content_type: mime)
    image.save
  end
end
