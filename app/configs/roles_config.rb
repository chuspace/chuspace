# frozen_string_literal: true

class RolesConfig < ApplicationConfig
  attr_config(
    writer: :writer,
    editor: :editor,
    manager: :manager,
    owner: :owner,
    subscriber: :subscriber
  )

  def self.to_enum
    defaults
  end
end