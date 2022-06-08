# frozen_string_literal: true

class MembershipPolicy < ApplicationPolicy
  alias_rule :update?, :create?, :show?, :new?, :destroy?, to: :edit?
  delegate :publication, to: :record

  def index?
    true
  end

  def edit?
    publication.memberships.admins.exists?(user: user)
  end

  def destroy?
    !record.owner?
  end
end
