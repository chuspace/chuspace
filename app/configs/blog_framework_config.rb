# frozen_string_literal: true

class BlogFrameworkConfig < ApplicationConfig
  attr_config(
    astro: {
      framework: 'astro',
      language: 'javascript',
      template_url: 'https://git.chuspace.com/chuspace/astro',
      posts_folder: 'src/pages/posts',
      drafts_folder: 'src/pages/posts',
      assets_folder: 'public/assets/blog'
    },
    bridgetown: {
      framework: 'bridgetown',
      language: 'ruby',
      template_url: 'https://git.chuspace.com/chuspace/bridgetown',
      posts_folder: 'src/pages/posts',
      drafts_folder: 'src/pages/posts',
      assets_folder: 'public/assets/blog'
    },
    gatsby: {
      framework: 'gatsby',
      language: 'javascript',
      template_url: 'https://git.chuspace.com/chuspace/gatsby',
      posts_folder: 'src/pages/posts',
      drafts_folder: 'src/pages/posts',
      assets_folder: 'public/assets/blog'
    },
    jekyll: {
      framework: 'jekyll',
      language: 'ruby',
      template_url: 'https://git.chuspace.com/chuspace/jekyll',
      posts_folder: 'src/pages/posts',
      drafts_folder: 'src/pages/posts',
      assets_folder: 'public/assets/blog'
    },
    hugo: {
      framework: 'hugo',
      language: 'go',
      template_url: 'https://git.chuspace.com/chuspace/hugo',
      posts_folder: 'src/pages/posts',
      drafts_folder: 'src/pages/posts',
      assets_folder: 'public/assets/blog'
    },
    eleventy: {
      framework: 'eleventy',
      language: 'javascript',
      template_url: 'https://git.chuspace.com/chuspace/eleventy',
      posts_folder: 'src/pages/posts',
      drafts_folder: 'src/pages/posts',
      assets_folder: 'public/assets/blog'
    },
    hexo: {
      framework: 'hexo',
      language: 'javascript',
      template_url: 'https://git.chuspace.com/chuspace/hexo',
      posts_folder: 'src/pages/posts',
      drafts_folder: 'src/pages/posts',
      assets_folder: 'public/assets/blog'
    },
    publish: {
      framework: 'publish',
      language: 'javascript',
      template_url: 'https://git.chuspace.com/chuspace/publish',
      posts_folder: 'src/pages/posts',
      drafts_folder: 'src/pages/posts',
      assets_folder: 'public/assets/blog'
    },
    nextjs: {
      framework: 'nextjs',
      language: 'javascript',
      template_url: 'https://git.chuspace.com/chuspace/nextjs',
      posts_folder: 'src/pages/posts',
      drafts_folder: 'src/pages/posts',
      assets_folder: 'public/assets/blog'
    },
    nuxtjs: {
      framework: 'nuxtjs',
      language: 'javascript',
      template_url: 'https://git.chuspace.com/chuspace/nuxtjs',
      posts_folder: 'src/pages/posts',
      drafts_folder: 'src/pages/posts',
      assets_folder: 'public/assets/blog'
    },
    gridsome: {
      framework: 'gridsome',
      language: 'javascript',
      template_url: 'https://git.chuspace.com/chuspace/gridsome',
      posts_folder: 'src/pages/posts',
      drafts_folder: 'src/pages/posts',
      assets_folder: 'public/assets/blog'
    },
    sculpin: {
      framework: 'sculpin',
      language: 'php',
      template_url: 'https://git.chuspace.com/chuspace/sculpin',
      posts_folder: 'src/pages/posts',
      drafts_folder: 'src/pages/posts',
      assets_folder: 'public/assets/blog'
    },
    pelican: {
      framework: 'pelican',
      language: 'python',
      template_url: 'https://git.chuspace.com/chuspace/pelican',
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
end
