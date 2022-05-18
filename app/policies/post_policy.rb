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

  def edit?
    publication.memberships.writers.exists?(user: user)
  end

  def revise?
    publication.members.exclude?(user)
  end

  def create?
    publication.memberships.publishers.exists?(user: user)
  end

  scope_for :relation, :author do |relation|
    relation.where(author_id: user.id)
  end
end
