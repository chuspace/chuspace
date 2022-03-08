# frozen_string_literal: true

class PostPolicy < ApplicationPolicy
  alias_rule :index?, :update?, :show?, :new?, :destroy?, to: :create?

  def create?
    true
  end
end
