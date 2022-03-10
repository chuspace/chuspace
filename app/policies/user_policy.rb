# frozen_string_literal: true

class UserPolicy < ApplicationPolicy
  def show?
    true
  end

  def edit?
    user == record
  end
end
