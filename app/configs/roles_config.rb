# frozen_string_literal: true

class RolesConfig < ApplicationConfig
  attr_config(
    writer: 'writer',
    editor: 'editor',
    admin: 'admin',
    owner: 'owner',
    member: 'member'
  )

  class << self
    def admins
      %w[admin owner]
    end

    def editors
      %w[writer editor admin owner]
    end

    def invitable_enum
      defaults.except('owner')
    end

    def permissions
      {
        writer: 'read . write',
        editor: 'read . write . publish',
        admin: 'read . write . publish . admin',
        member: 'read'
      }
    end

    def publishers
      %w[editor admin owner]
    end

    def to_enum
      defaults
    end
  end
end
