# frozen_string_literal: true

module PostHelper
  def social_share_url(post:, provider:)
    case provider.to_sym
    when :facebook then "https://www.facebook.com/sharer.php?u=#{publication_post_url(post.publication, post)}"
    when :twitter then "https://twitter.com/intent/tweet?url=#{publication_post_url(post.publication, post)}"
    when :linkedin then "https://www.linkedin.com/shareArticle?url=#{publication_post_url(post.publication, post)}"
    when :email then "mailto:?subject=#{post.title}&body=#{publication_post_url(post.publication, post)}"
    end
  end
end
