# frozen_string_literal: true

class RolesConfig < ApplicationConfig
  attr_config(
    writer: 'writer',
    editor: 'editor',
    manager: 'manager',
    owner: 'owner',
    member: 'member'
  )

  def self.to_enum
    defaults
  end

  def self.editors
    %w[writer editor manager owner]
  end

  def self.managers
    %w[manager owner]
  end

  def self.publishers
    %w[editor manager owner]
  end
end
