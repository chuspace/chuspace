# frozen_string_literal: true

class BlogFrameworkConfig < ApplicationConfig
  attr_config(
    astro: {
      framework: 'astro',
      default: true,
      language: 'javascript',
      template_name: 'chuspace-contrib/astro-starter-blog',
      template_url: 'https://github.com/chuspace-contrib/astro-starter-blog.git',
      posts_folder: 'src/pages/posts',
      drafts_folder: 'src/pages/posts',
      assets_folder: 'public/assets/blog'
    },
    gatsby: {
      framework: 'gatsby',
      language: 'javascript',
      default: false,
      template_name: 'chuspace-contrib/gatsby-starter-blog',
      template_url: 'https://github.com/chuspace-contrib/gatsby-starter-blog.git',
      posts_folder: 'src/pages/posts',
      drafts_folder: 'src/pages/posts',
      assets_folder: 'public/assets/blog'
    },
    jekyll: {
      framework: 'jekyll',
      language: 'ruby',
      default: false,
      template_name: 'chuspace-contrib/jekyll-starter-blog',
      template_url: 'https://github.com/chuspace-contrib/jekyll-starter-blog.git',
      posts_folder: 'src/pages/posts',
      drafts_folder: 'src/pages/posts',
      assets_folder: 'public/assets/blog'
    },
    hugo: {
      framework: 'hugo',
      language: 'go',
      default: false,
      template_name: 'chuspace-contrib/hugo-starter-blog',
      template_url: 'https://github.com/chuspace-contrib/hugo-starter-blog.git',
      posts_folder: 'content/post',
      drafts_folder: 'content/post',
      assets_folder: 'static'
    },
    eleventy: {
      framework: 'eleventy',
      language: 'javascript',
      default: false,
      template_name: 'chuspace-contrib/eleventy-starter-blog',
      template_url: 'https://github.com/chuspace-contrib/eleventy-starter-blog.git',
      posts_folder: 'src/pages/posts',
      drafts_folder: 'src/pages/posts',
      assets_folder: 'public/assets/blog'
    },
    nextjs: {
      framework: 'nextjs',
      language: 'javascript',
      default: false,
      template_name: 'chuspace-contrib/nextjs-starter-blog',
      template_url: 'https://github.com/chuspace-contrib/nextjs-starter-blog.git',
      posts_folder: 'src/pages/posts',
      drafts_folder: 'src/pages/posts',
      assets_folder: 'public/assets/blog'
    },
    nuxtjs: {
      framework: 'nuxtjs',
      language: 'javascript',
      default: false,
      template_name: 'chuspace-contrib/nuxtjs-starter-blog',
      template_url: 'https://github.com/chuspace-contrib/nuxtjs-starter-blog.git',
      posts_folder: 'src/pages/posts',
      drafts_folder: 'src/pages/posts',
      assets_folder: 'public/assets/blog'
    }
  )

  def self.frameworks_enum
    defaults.keys.each_with_object({}) do |key, hash|
      hash[key.to_sym] = key
    end
  end

  def self.default
    defaults.values.find do |value|
      value['default']
    end
  end
end
