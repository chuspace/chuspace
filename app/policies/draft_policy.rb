# frozen_string_literal: true

class DraftPolicy < ApplicationPolicy
  alias_rule :autosave?, :update?, :destroy?, to: :edit?
  alias_rule :create?, :index?, to: :new?

  delegate :publication, to: :record

  def commit?
    edit? && record.stale?
  end

  def edit?
    record.persisted?
  end

  def new?
    publication.memberships.writers.exists?(user: user)
  end

  def publish?
    publication.memberships.publishers.exists?(user: user) && record.publishable?
  end
end
