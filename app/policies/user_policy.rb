# frozen_string_literal: true

class UserPolicy < ApplicationPolicy
  alias_rule :index?, :create?, :show?, :new?, to: :show?
  alias_rule :update?, :destroy?, :drafts?, to: :edit?

  def show?
    true
  end

  def edit?
    user == record
  end
end
