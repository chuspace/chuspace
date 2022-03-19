# frozen_string_literal: true

class CollaborationSessionMemberPolicy < ApplicationPolicy
  alias_rule :index?, :update?, :show?, :edit, :new?, :destroy?, to: :create?

  def create?
    record.publication.memberships.writers.exists?(user: user)
  end
end
