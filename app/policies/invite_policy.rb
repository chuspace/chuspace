# frozen_string_literal: true

class InvitePolicy < ApplicationPolicy
  alias_rule :index?, :update?, :new?, :show?, :destroy?, to: :create?

  def create?
    owner? || record.publication.memberships.admins.where(user: user).exists?
  end

  def accept?
    record.recipient == user
  end

  private

  def owner?
    record.publication.owner == user
  end
end
