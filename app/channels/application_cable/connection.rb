# frozen_string_literal: true

module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :current_identity, :current_user

    def connect
      self.current_identity = find_identity
      self.current_user = current_identity.user

      Current.identity = current_identity

      logger.add_tags current_user.name
    end

    def disconnect
      Current.identity = nil
      self.current_identity = nil
      self.current_user = nil
    end

    private

    def find_identity
      Identity.find_by(id: cookies.encrypted[:identity_id]) || reject_unauthorized_connection
    end
  end
end
