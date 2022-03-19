# frozen_string_literal: true

class CollaborationSessionPolicy < ApplicationPolicy
  alias_rule :index?, :update?, :show?, :edit, :new?, to: :create?

  def create?
    record.members.exists?(user: user)
  end

  def destroy?
    false
  end
end
