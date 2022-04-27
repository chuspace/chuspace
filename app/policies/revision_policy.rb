# frozen_string_literal: true

class RevisionPolicy < ApplicationPolicy
  alias_rule :new?, to: :create?
  alias_rule :update?, :destroy?, to: :edit?

  delegate :publication, to: :record

  # Only limit outside
  def index?
    true
  end

  def create?
    true
  end

  def edit?
    record.author == user
  end
end
