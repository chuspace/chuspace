# frozen_string_literal: true

source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '3.0.0'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '>= 6.x'

# Use postgresql as the database for Active Record
gem 'pg', '>= 1.x'
gem 'strong_migrations'
gem 'database_validations'
gem 'activerecord-clean-db-structure'
gem 'name_of_person'
gem 'friendly_id'

# File uploads
gem 'aws-sdk-s3'
gem 'mini_mime'
gem 'fastimage'
gem 'image_processing'
gem 'ruby-vips'
gem 'shrine'
gem 'shrine-memory', require: false

# SES
gem 'aws-ses', require: 'aws/ses'

# Nested tree
gem 'ancestry'

# Use Puma as the app server
gem 'puma', '>= 3.11'

# Transpile app-like JavaScript. Read more: https://github.com/rails/webpacker
gem 'webpacker', '6.0.0.beta.6'

# Use Redis adapter to run Action Cable in production
gem 'delayed_job_active_record'

# Sitemap
gem 'sitemap_generator', require: false

# State machine
gem 'aasm'

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', '>= 1.1.0', require: false

# Turblinks
gem 'turbolinks'

# Instrumentation
gem 'yabeda'

# View components
gem 'view_component'

# Omninauth
gem 'omniauth-github', github: 'omniauth/omniauth-github', branch: 'master'

# Security
gem 'rack-attack'

# Markdown
gem 'commonmarker'

# Friendly urls
gem 'babosa', github: 'empathyby/babosa'

# Github data
gem 'octokit', require: false

#  SEO
gem 'meta-tags'

# User visit tracking
gem 'ahoy_matey'
gem 'maxminddb'

# Error tracking
gem 'sentry-raven'

# Cron jobs
gem 'whenever', require: false

# Icons
gem 'octicons_helper'

group :production do
  # Resource monitoring
  gem 'easymon'
end

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
  gem 'rspec_junit_formatter'
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
