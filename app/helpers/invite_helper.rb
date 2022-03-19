# frozen_string_literal: true

module InviteHelper
  def invitable_roles_collection
    Invite.roles.map do |(key, value)|
      label = "#{key.humanize} - #{RolesConfig.permissions[key.to_sym]}"
      [value, label]
    end
  end
end
