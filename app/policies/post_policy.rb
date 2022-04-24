# frozen_string_literal: true

class PostPolicy < ApplicationPolicy
  alias_rule :new?, :destroy?, to: :create?
  delegate :publication, to: :record

  def index?
    true
  end

  def show?
    true
  end

  def update?
    false
  end

  def destroy?
    false
  end

  def revise?
    publication.members.exclude?(user)
  end

  def create?
    publication.memberships.publishers.exists?(user: user)
  end
end
