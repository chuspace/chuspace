# frozen_string_literal: true

module Trackable
  extend ActiveSupport::Concern

  def set_tracked_fields(request)
    old_current, new_current = self.current_sign_in_at, Time.current.utc
    self.last_sign_in_at = old_current || new_current
    self.current_sign_in_at = new_current

    old_current, new_current = self.current_sign_in_ip, request.remote_ip
    self.last_sign_in_ip = old_current || new_current
    self.current_sign_in_ip = new_current

    self.sign_in_count ||= 0
    self.sign_in_count += 1
  end

  def update_tracked_fields!(request)
    set_tracked_fields(request)
    self.save!
  end
end
