# frozen_string_literal: true

ENV['RAILS_ENV'] = 'test'

require_relative '../config/environment'
require 'rails/test_help'
require 'simplecov'
require 'simplecov-lcov'

SimpleCov::Formatter::LcovFormatter.config.report_with_single_file = true
SimpleCov.formatter = SimpleCov::Formatter::LcovFormatter
SimpleCov.start 'rails' do
  add_filter(%r{^\/test|bin|db|config|views|javascript|lib\/})
end

class ActiveSupport::TestCase
  include FactoryBot::Syntax::Methods
  include ActiveJob::TestHelper
  fixtures :all
  self.use_transactional_tests = true

  setup { ActiveJob::Base.queue_adapter = :test }
end
