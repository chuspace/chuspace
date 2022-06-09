# frozen_string_literal: true

class DraftPolicy < ApplicationPolicy
  alias_rule :autosave?, :update?, :destroy?, to: :edit?
  alias_rule :create?, :index?, :new?, to: :write?

  delegate :publication, to: :record

  def commit?
    edit? && record.stale?
  end

  def edit?
    record.persisted? && write?
  end

  def action?
    commit? || publish?
  end

  def write?
    publication.memberships.writers.exists?(user: user)
  end

  def publish?
    publication.memberships.publishers.exists?(user: user) && record.publishable?
  end
  
  def republish?
    publication.memberships.publishers.exists?(user: user) && record.post.present? && !record.stale?
  end
end
