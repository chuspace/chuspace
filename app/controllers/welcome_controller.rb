# frozen_string_literal: true

class WelcomeController < ApplicationController
  layout 'marketing'
  skip_verify_authorized
end
