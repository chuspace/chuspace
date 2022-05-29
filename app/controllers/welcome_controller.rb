# frozen_string_literal: true

class WelcomeController < ApplicationController
  skip_verify_authorized
  layout 'marketing'
end
