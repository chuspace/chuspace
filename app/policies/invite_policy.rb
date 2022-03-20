# frozen_string_literal: true

class InvitePolicy < ApplicationPolicy
  alias_rule :index?, :update?, :new?, :show?, :destroy?, to: :create?
  delegate :publication, to: :record

  def create?
    publication.memberships.admins.where(user: user).exists?
  end

  def accept?
    record.recipient == user
  end
end
