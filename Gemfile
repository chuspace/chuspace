# frozen_string_literal: true

source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '3.0.2'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 6.x'

# Use postgresql as the database for Active Record
gem 'pg', '>= 1.x'
gem 'strong_migrations'
gem 'database_validations'
gem 'activerecord-clean-db-structure'
gem 'friendly_id'
gem 'babosa'
gem 'action_policy'

# File uploads
gem 'image_processing'
gem 'ruby-vips'

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
gem 'webpacker', '6.0.0.rc.1'

# Sitemap
gem 'sitemap_generator', require: false

# State machine
gem 'aasm'

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', '>= 1.1.0', require: false

# Turblinks
gem 'turbo-rails'

# View components
gem 'view_component'

# Omninauth
gem 'omniauth-github', github: 'omniauth/omniauth-github'
gem 'omniauth-gitlab', github: 'linchus/omniauth-gitlab'
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
gem 'sawyer'
gem 'faraday-http-cache'

#  SEO
gem 'meta-tags'

# Error tracking
gem 'sentry-ruby'
gem 'sentry-rails'

# SVG
gem 'inline_svg'

# Encryption
gem 'blind_index'
gem 'lockbox'

# App configs
gem 'anyway_config'

group :production do
  # Resource monitoring
  gem 'easymon'
end

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
  gem 'rspec_junit_formatter'
  gem 'rspec-rails'
  gem 'factory_bot_rails'
  gem 'faker'
  gem 'coveralls', require: false
  gem 'minitest'
  gem 'rack-proxy'
  gem 'rack-mini-profiler'
end

group :development do
  gem 'web-console', '>= 3.3.0', require: false
  # Code linting
  gem 'rubocop', require: false
  gem 'rubocop-rails', require: false
  gem 'rubocop-performance', require: false
  gem 'bullet'
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
