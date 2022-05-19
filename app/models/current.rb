# frozen_string_literal: true

class Current < ActiveSupport::CurrentAttributes
  attribute :identity, :user
  attribute :request_id, :user_agent, :ip_address

  def identity=(identity)
    self.user = identity&.user

    super
  end

  def request_authenticated?
    (identity && user).present?
  end
end
