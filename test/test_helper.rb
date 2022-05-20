# frozen_string_literal: true

ENV['RAILS_ENV'] = 'test'

require 'simplecov'
require 'simplecov_json_formatter'
SimpleCov.formatter = SimpleCov::Formatter::JSONFormatter
SimpleCov.start 'rails' do
  add_filter(%r{^\/test|bin|db|config|views|javascript|lib\/})
end

require_relative '../config/environment'
require 'rails/test_help'
require 'action_policy/test_helper'

class ActiveSupport::TestCase
  include FactoryBot::Syntax::Methods
  include ActiveJob::TestHelper
  include ActionMailer::TestHelper
  include ActiveSupport::Testing::TimeHelpers
  include ActionPolicy::TestHelper

  fixtures :all
  self.use_transactional_tests = true

  setup { ActiveJob::Base.queue_adapter = :test }
end
