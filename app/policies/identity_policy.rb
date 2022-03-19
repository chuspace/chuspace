# frozen_string_literal: true

class IdentityPolicy < ApplicationPolicy
  alias_rule :index?, :show?, :new?, :create?, to: :show?
  alias_rule :update?, :destroy?, to: :edit?

  def show?
    true
  end

  def edit?
    user == identity.user
  end
end
