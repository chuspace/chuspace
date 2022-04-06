# frozen_string_literal: true

class ChuspaceConfig < ApplicationConfig
  attr_config(app_name: 'Chuspace', twitter: '@chuspace_com', out_of_private_beta: ENV.fetch('OUT_OF_PRIVATE_BETA') || true)
end
