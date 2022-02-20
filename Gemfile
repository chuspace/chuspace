# frozen_string_literal: true

source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '3.1.0'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 7.x'

# Use postgresql as the database for Active Record
gem 'pg', '>= 1.x'
gem 'strong_migrations'
gem 'database_validations'
gem 'friendly_id'
gem 'babosa'
gem 'action_policy'
gem 'name_of_person'
gem 'good_job'
gem 'mini_mime'
gem 'wicked'
gem 'kredis'

# JSONB attributes
gem 'active_type'
gem 'attr_json'

# Cache
gem 'hiredis'
gem 'oj'
gem 'redis'

# Sprockets
gem 'sprockets-rails'

# Tagging
gem 'acts-as-taggable-on', github: 'mbleigh/acts-as-taggable-on'

# Form
gem 'simple_form'

# Emails
gem 'aws-ses', require: 'aws/ses'
gem 'aws-sdk-rails'
gem 'aws-sdk-s3'

# Nested tree
gem 'ancestry'

# Use Puma as the app server
gem 'puma', '>= 3.11'

# Transpile app-like JavaScript. Read more: https://github.com/rails/webpacker
gem 'webpacker', '6.0.0.rc.5'

# Sitemap
gem 'sitemap_generator', require: false

# State machine
gem 'aasm'

# Search
gem 'meilisearch-rails'

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', '>= 1.1.0', require: false

# Turblinks
gem 'turbo-rails'

# Omninauth
gem 'omniauth-github', github: 'omniauth/omniauth-github'
gem 'omniauth-gitlab', github: 'linchus/omniauth-gitlab'
gem 'omniauth-atlassian-bitbucket', github: 'fnando/omniauth-atlassian-bitbucket'
gem 'omniauth-rails_csrf_protection'

# Security
gem 'rack-attack'

# Markdown
gem 'commonmarker'
gem 'front_matter_parser'

# Clients
gem 'down'
gem 'http'
gem 'faraday'
gem 'sawyer', github: 'lostisland/sawyer'
gem 'faraday-http-cache'
gem 'typhoeus'

gem 'fast_diff', path: '/Users/gaurav/oss/fast_diff'
gem 'diffy'

#  SEO
gem 'meta-tags'

# Error tracking
gem 'sentry-ruby'
gem 'sentry-rails'

# SVG
gem 'inline_svg'

# App configs
gem 'anyway_config'

# Analytics
gem 'ahoy_matey'
gem 'maxminddb'

group :production do
  # Resource monitoring
  gem 'easymon'
end

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
  gem 'factory_bot_rails'
  gem 'faker'
  gem 'coveralls', require: false
  gem 'minitest'
  gem 'rack-proxy'
  gem 'rack-mini-profiler'
  gem 'dotenv-rails'
end

group :development do
  gem 'erb_lint', require: false
  gem 'htmlbeautifier', require: false

  gem 'web-console', '>= 3.3.0', require: false
  # Code linting
  gem 'rubocop', require: false
  gem 'rubocop-rails', require: false
  gem 'rubocop-performance', require: false
  # Security
  gem 'brakeman', require: false
  gem 'bundler-audit', require: false
  # Better messages
  gem 'awesome_print'
  # Pry
  gem 'pry-rails'

  gem 'database_consistency', require: false
  gem 'tomo', require: false
end

group :test do
  gem 'simplecov', require: false
  gem 'simplecov-lcov', require: false
  gem 'rails-controller-testing'
  gem 'capybara'
  gem 'selenium-webdriver'
  gem 'webdrivers'
end
gem "graphiql-rails", group: :development
