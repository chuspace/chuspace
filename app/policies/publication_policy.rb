# frozen_string_literal: true

class PublicationPolicy < ApplicationPolicy
  alias_rule :destroy?, :update?, :invite?, to: :edit?
  alias_rule :create?, :show?, :index?, to: :new?

  def new?
    true
  end

  def edit?
    record.memberships.admins.exists?(user: user)
  end

  def write?
    record.memberships.writers.exists?(user: user)
  end

  def publish?
    record.memberships.publishers.exists?(user: user)
  end

  relation_scope { |relation| relation.joins(:members).where(memberships: { user_id: user.id }) }
end
