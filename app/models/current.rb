# frozen_string_literal: true

class Current < ActiveSupport::CurrentAttributes
  attribute :identity, :user, :personal_blog
  attribute :request_id, :user_agent, :ip_address

  def identity=(identity)
    self.user = identity&.user
    self.personal_blog = identity&.user&.personal_blog

    super
  end
end
