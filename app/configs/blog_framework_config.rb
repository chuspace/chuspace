# frozen_string_literal: true

class BlogFrameworkConfig < ApplicationConfig
  attr_config(
    astro: {
      framework: 'astro',
      default: true,
      language: 'javascript',
      template_name: 'chuspace/astro-starter-blog',
      posts_folder: 'src/pages/posts',
      drafts_folder: 'src/pages/posts',
      assets_folder: 'public/assets/blog'
    },
    bridgetown: {
      framework: 'bridgetown',
      language: 'javascript',
      default: false,
      template_name: 'chuspace/bridgetown-starter-blog',
      posts_folder: 'src/_posts',
      drafts_folder: 'src/_posts',
      assets_folder: 'src/images'
    },
    eleventy: {
      framework: 'eleventy',
      language: 'javascript',
      default: false,
      template_name: 'chuspace/11ty-starter-blog',
      posts_folder: 'src/blog',
      drafts_folder: 'src/blog',
      assets_folder: 'src/blog'
    },
    gridsome: {
      framework: 'gridsome',
      language: 'javascript',
      default: false,
      template_name: 'chuspace/gridsome-starter-blog',
      posts_folder: 'content/posts',
      drafts_folder: 'content/posts',
      assets_folder: 'static'
    },
    gatsby: {
      framework: 'gatsby',
      language: 'javascript',
      default: false,
      template_name: 'chuspace/gatsby-starter-blog',
      posts_folder: 'src/posts',
      drafts_folder: 'src/posts',
      assets_folder: 'src/images'
    },
    hexo: {
      framework: 'hexo',
      language: 'javascript',
      default: false,
      template_name: 'chuspace/hexo-starter-blog',
      posts_folder: 'source/_posts',
      drafts_folder: 'source/_posts',
      assets_folder: 'source/images'
    },
    hugo: {
      framework: 'hugo',
      language: 'go',
      default: false,
      template_name: 'chuspace/hugo-starter-blog',
      posts_folder: 'content/posts',
      drafts_folder: 'content/posts',
      assets_folder: 'static'
    },
    jekyll: {
      framework: 'jekyll',
      language: 'ruby',
      default: false,
      template_name: 'chuspace/jekyll-starter-blog',
      posts_folder: '_posts',
      drafts_folder: '_drafts',
      assets_folder: 'assets/img'
    },
    nextjs: {
      framework: 'nextjs',
      language: 'javascript',
      default: false,
      template_name: 'chuspace/nextjs-starter-blog',
      posts_folder: '_posts',
      drafts_folder: '_posts',
      assets_folder: 'public/images'
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
