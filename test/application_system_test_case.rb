# frozen_string_literal: true

require 'test_helper'
require 'capybara/rails'
require 'capybara/minitest'

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  driven_by :selenium, using: :chrome, screen_size: [1_400, 1_400]
end
