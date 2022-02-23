# frozen_string_literal: true

class DraftPolicy < ApplicationPolicy
  alias_rule :index?, :update?, :create?, :show?, :new?, :destroy?, to: :edit?

  def autosave?
    edit? && (record.editor_lock.blank? || record.editor_lock.owner == user)
  end

  def commit?
    edit? && (record.stale? && record.editor_lock.owner == user)
  end

  def edit?
    owner? || record.editors.where(user: user).exists?
  end

  def publish?
    owner? || record.publishers.where(user: user).exists?
  end

  private

  def owner?
    user == record.owner
  end
end
