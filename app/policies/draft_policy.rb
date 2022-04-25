# frozen_string_literal: true

class DraftPolicy < ApplicationPolicy
  alias_rule :autosave?, :index?, :update?, :create?, :commit?, :show?, :new?, :destroy?, to: :edit?
  delegate :publication, to: :record

  def edit?
    publication.memberships.writers.exists?(user: user)
  end

  def publish?
    publication.memberships.publishers.exists?(user: user) && record.publishable?
  end
end
