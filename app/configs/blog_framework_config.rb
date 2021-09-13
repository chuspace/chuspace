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
    bridgetown: {
      framework: 'bridgetown',
      language: 'ruby',
      default: false,
      template_name: 'chuspace-contrib/bridgetown-starter-blog',
      template_url: 'https://github.com/chuspace-contrib/bridgetown',
      posts_folder: 'src/pages/posts',
      drafts_folder: 'src/pages/posts',
      assets_folder: 'public/assets/blog'
    },
    gatsby: {
      framework: 'gatsby',
      language: 'javascript',
      default: false,
      template_name: 'chuspace-contrib/gatsby-starter-blog',
      template_url: 'https://github.com/chuspace-contrib/gatsby',
      posts_folder: 'src/pages/posts',
      drafts_folder: 'src/pages/posts',
      assets_folder: 'public/assets/blog'
    },
    jekyll: {
      framework: 'jekyll',
      language: 'ruby',
      default: false,
      template_name: 'chuspace-contrib/jekyll-starter-blog',
      template_url: 'https://github.com/chuspace-contrib/jekyll',
      posts_folder: 'src/pages/posts',
      drafts_folder: 'src/pages/posts',
      assets_folder: 'public/assets/blog'
    },
    hugo: {
      framework: 'hugo',
      language: 'go',
      default: false,
      template_name: 'chuspace-contrib/hugo-starter-blog',
      template_url: 'https://github.com/chuspace-contrib/hugo',
      posts_folder: 'src/pages/posts',
      drafts_folder: 'src/pages/posts',
      assets_folder: 'public/assets/blog'
    },
    eleventy: {
      framework: 'eleventy',
      language: 'javascript',
      default: false,
      template_name: 'chuspace-contrib/eleventy-starter-blog',
      template_url: 'https://github.com/chuspace-contrib/eleventy',
      posts_folder: 'src/pages/posts',
      drafts_folder: 'src/pages/posts',
      assets_folder: 'public/assets/blog'
    },
    hexo: {
      framework: 'hexo',
      language: 'javascript',
      default: false,
      template_name: 'chuspace-contrib/hexo-starter-blog',
      template_url: 'https://github.com/chuspace-contrib/hexo',
      posts_folder: 'src/pages/posts',
      drafts_folder: 'src/pages/posts',
      assets_folder: 'public/assets/blog'
    },
    publish: {
      framework: 'publish',
      language: 'javascript',
      default: false,
      template_name: 'chuspace-contrib/publish-starter-blog',
      template_url: 'https://github.com/chuspace-contrib/publish',
      posts_folder: 'src/pages/posts',
      drafts_folder: 'src/pages/posts',
      assets_folder: 'public/assets/blog'
    },
    nextjs: {
      framework: 'nextjs',
      language: 'javascript',
      default: false,
      template_name: 'chuspace-contrib/nextjs-starter-blog',
      template_url: 'https://github.com/chuspace-contrib/nextjs',
      posts_folder: 'src/pages/posts',
      drafts_folder: 'src/pages/posts',
      assets_folder: 'public/assets/blog'
    },
    nuxtjs: {
      framework: 'nuxtjs',
      language: 'javascript',
      default: false,
      template_name: 'chuspace-contrib/nuxtjs-starter-blog',
      template_url: 'https://github.com/chuspace-contrib/nuxtjs',
      posts_folder: 'src/pages/posts',
      drafts_folder: 'src/pages/posts',
      assets_folder: 'public/assets/blog'
    },
    gridsome: {
      framework: 'gridsome',
      language: 'javascript',
      default: false,
      template_name: 'chuspace-contrib/gridsome-starter-blog',
      template_url: 'https://github.com/chuspace-contrib/gridsome',
      posts_folder: 'src/pages/posts',
      drafts_folder: 'src/pages/posts',
      assets_folder: 'public/assets/blog'
    },
    sculpin: {
      framework: 'sculpin',
      language: 'php',
      default: false,
      template_name: 'chuspace-contrib/sculpin-starter-blog',
      template_url: 'https://github.com/chuspace-contrib/sculpin',
      posts_folder: 'src/pages/posts',
      drafts_folder: 'src/pages/posts',
      assets_folder: 'public/assets/blog'
    },
    pelican: {
      framework: 'pelican',
      language: 'python',
      default: false,
      template_name: 'chuspace-contrib/pelican-starter-blog',
      template_url: 'https://github.com/chuspace-contrib/pelican',
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
