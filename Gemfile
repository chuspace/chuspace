# frozen_string_literal: true

source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '3.1.1'

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

# Sign web tokens
gem 'jwt'

# JSONB attributes
gem 'active_type'
gem 'attr_json'

# Redis WS
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

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', '>= 1.1.0', require: false

# Full-text search
gem 'pg_search'

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
gem 'sentry-ruby'
gem 'sentry-rails'

# SVG
gem 'inline_svg'

# App configs
gem 'anyway_config'

# Analytics
gem 'ahoy_matey'
gem 'maxminddb'

# Votable
gem 'acts_as_votable'

# View component
gem 'view_component'

group :production do
  # Resource monitoring
  gem 'easymon'
end

# JS runtime
gem 'execjs'

# Deployment
gem 'tomo'
gem 'tomo-plugin-good_job'

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
end

group :test do
  gem 'simplecov', require: false
  gem 'simplecov-lcov', require: false
  gem 'rails-controller-testing'
  gem 'capybara'
  gem 'selenium-webdriver'
  gem 'webdrivers'
end
