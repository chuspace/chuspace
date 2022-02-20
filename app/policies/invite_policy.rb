# frozen_string_literal: true

class InvitePolicy < ApplicationPolicy
  def new?
    record.publication.owner == user
  end

  alias create? new?

  def accept?
    record.recipient == user
  end
end
