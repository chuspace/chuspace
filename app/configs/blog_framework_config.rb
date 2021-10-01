# frozen_string_literal: true

class BlogFrameworkConfig < ApplicationConfig
  attr_config(
    astro: {
      framework: 'astro',
      default: true,
      language: 'javascript',
      template_name: 'chuspace/astro-starter-blog',
      repo_articles_path: 'src/pages/posts',
      repo_drafts_path: 'src/pages/posts',
      repo_assets_path: 'public/assets/blog',
      repo_about_path: 'src/pages/about.md'
    },
    bridgetown: {
      framework: 'bridgetown',
      language: 'javascript',
      default: false,
      template_name: 'chuspace/bridgetown-starter-blog',
      repo_articles_path: 'src/_posts',
      repo_drafts_path: 'src/_posts',
      repo_assets_path: 'src/images',
      repo_about_path: 'src/about.md'
    },
    eleventy: {
      framework: 'eleventy',
      language: 'javascript',
      default: false,
      template_name: 'chuspace/11ty-starter-blog',
      repo_articles_path: 'src/blog',
      repo_drafts_path: 'src/blog',
      repo_assets_path: 'src/blog',
      repo_about_path: 'src/about.md'
    },
    gridsome: {
      framework: 'gridsome',
      language: 'javascript',
      default: false,
      template_name: 'chuspace/gridsome-starter-blog',
      repo_articles_path: 'content/posts',
      repo_drafts_path: 'content/posts',
      repo_assets_path: 'static',
      repo_about_path: 'content/about.md'
    },
    gatsby: {
      framework: 'gatsby',
      language: 'javascript',
      default: false,
      template_name: 'chuspace/gatsby-starter-blog',
      repo_articles_path: 'content/posts',
      repo_drafts_path: 'content/drafts',
      repo_assets_path: 'static/images',
      repo_about_path: 'content/pages/about.md'
    },
    hexo: {
      framework: 'hexo',
      language: 'javascript',
      default: false,
      template_name: 'chuspace/hexo-starter-blog',
      repo_articles_path: 'source/_posts',
      repo_drafts_path: 'source/_posts',
      repo_assets_path: 'source/images',
      repo_about_path: 'source/pages/about.md'
    },
    hugo: {
      framework: 'hugo',
      language: 'go',
      default: false,
      template_name: 'chuspace/hugo-starter-blog',
      repo_articles_path: 'content/posts',
      repo_drafts_path: 'content/posts',
      repo_assets_path: 'static',
      repo_about_path: 'content/pages/about.md'
    },
    jekyll: {
      framework: 'jekyll',
      language: 'ruby',
      default: false,
      template_name: 'chuspace/jekyll-starter-blog',
      repo_articles_path: '_posts',
      repo_drafts_path: '_drafts',
      repo_assets_path: 'assets/img',
      repo_about_path: 'about.md'
    },
    nextjs: {
      framework: 'nextjs',
      language: 'javascript',
      default: false,
      template_name: 'chuspace/nextjs-starter-blog',
      repo_articles_path: '_posts',
      repo_drafts_path: '_drafts',
      repo_assets_path: 'public/images',
      repo_about_path: '_pages/about.md'
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
