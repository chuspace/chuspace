# frozen_string_literal: true

Rails.application.configure do
  config.content_security_policy do |policy|
    policy.default_src :self, :https
    policy.font_src    :self, :https, :data
    policy.img_src     :self, :https, :data, 'https://images.chuspace.com', 'https://secure.gravatar.com', 'http://secure.gravatar.com', '*.s3.amazonaws.com'
    policy.object_src  :none
    policy.script_src  :self, :https, 'https://assets.chuspace.com', :unsafe_inline
    policy.style_src   :self, :https, 'https://assets.chuspace.com', :unsafe_inline, :unsafe_eval

    policy.connect_src :self, :https, 'http://localhost:3035', 'ws://localhost:3035' if Rails.env.development?
  end

  # Generate session nonces for permitted importmap and inline scripts
  config.content_security_policy_nonce_generator  = ->(request) { request.session.id.to_s }
  config.content_security_policy_nonce_directives = %w(script-src)
  config.content_security_policy_report_only      = false
end
