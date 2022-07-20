# frozen_string_literal: true

source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '3.1.2'

gem 'activerecord', '~> 7.x'
gem 'activemodel', '~> 7.x'
gem 'actionpack', '~> 7.x'
gem 'actionview', '~> 7.x'
gem 'actionmailer', '~> 7.x'
gem 'activejob', '~> 7.x'
gem 'activesupport', '~> 7.x'
gem 'activestorage', '~> 7.x'
gem 'railties', '~> 7.x'
gem 'sprockets-rails'
gem 'mysql2'
gem 'strong_migrations'
gem 'friendly_id'
gem 'babosa'
gem 'action_policy'
gem 'name_of_person'
gem 'mini_mime'
gem 'active_storage_validations'
gem 'rubyzip'
gem 'maybe_later'

# Sign web tokens
gem 'alba'
gem 'jwt'

# JSONB attributes
gem 'active_type'
gem 'attr_json'

# JSON
gem 'oj'

# Tagging
gem 'acts-as-taggable-on', github: 'mbleigh/acts-as-taggable-on'

# Form
gem 'simple_form'

# Emails
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

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', '>= 1.1.0', require: false

# Full-text search
gem 'algoliasearch-rails'

# Turblinks
gem 'turbo-rails'

# Omninauth
gem 'omniauth'
gem 'omniauth-oauth2'
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
gem 'faraday-retry'
gem 'faraday-typhoeus'
gem 'faraday-http-cache'
gem 'sawyer', github: 'lostisland/sawyer'
gem 'typhoeus'

# Image
gem 'image_processing'

# Text diff
gem 'diffy'

#  SEO
gem 'meta-tags'

# Error tracking
gem 'rollbar'

# SVG
gem 'inline_svg'

# App configs
gem 'anyway_config'

# Analytics
gem 'ahoy_matey'

# Votable
gem 'acts_as_votable'

# View component
gem 'view_component'

# Monitoring
gem 'skylight'
gem 'easymon'

group :production do
  gem 'cloudflare-rails'
  gem 'lograge'
  gem 'logtail-rails'
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

  gem 'colorize'

  # Deployment
  gem 'tomo'
  gem 'tomo-plugin-aws_sqs', '~> 1.0'
end

group :test do
  gem 'simplecov', require: false
  gem 'simplecov_json_formatter', require: false
  gem 'rails-controller-testing'
  gem 'capybara'
  gem 'selenium-webdriver'
  gem 'webdrivers'
end
