# frozen_string_literal: true

class GitProviderPolicy < ApplicationPolicy
  alias_rule :new?, :create?, to: :index?
  alias_rule :update?, :destroy?, :show?, to: :edit?

  def index?
    true
  end

  def setup?
    record.enabled? && edit?
  end

  def edit?
    record.user == user
  end

  relation_scope { |relation| relation.where(user_id: user.id) }
end
