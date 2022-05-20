# frozen_string_literal: true

class UserPolicy < ApplicationPolicy
  alias_rule :new?, to: :create?
  alias_rule :update?, :destroy?, :drafts?, to: :edit?

  def create?
    true
  end

  def edit?
    user == record
  end
end
