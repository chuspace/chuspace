# frozen_string_literal: true

require 'test_helper'
require 'capybara/rails'
require 'capybara/minitest'
require 'webdrivers'
require 'webdrivers/chromedriver'

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  include FactoryBot::Syntax::Methods
  include ActiveJob::TestHelper
  include ActionMailer::TestHelper
  include ActiveSupport::Testing::TimeHelpers
  include ActionPolicy::TestHelper

  DRIVER = if ENV['DRIVER']
    ENV['DRIVER'].to_sym
  else
    :headless_chrome
  end

  driven_by :selenium, using: DRIVER, screen_size: [1_400, 1_400]
end
