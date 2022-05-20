# frozen_string_literal: true

require 'test_helper'
require 'capybara/rails'
require 'capybara/minitest'

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  include FactoryBot::Syntax::Methods
  include ActiveJob::TestHelper
  include ActionMailer::TestHelper
  include ActiveSupport::Testing::TimeHelpers
  include ActionPolicy::TestHelper

  driven_by :selenium, using: :chrome, screen_size: [1_400, 1_400]
end
