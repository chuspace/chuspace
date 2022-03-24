# frozen_string_literal: true

class WelcomeController < ApplicationController
  skip_verify_authorized
  skip_before_action :private_beta_stop
  layout 'marketing'
end
