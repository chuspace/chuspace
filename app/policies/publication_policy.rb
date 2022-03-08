# frozen_string_literal: true

class PublicationPolicy < ApplicationPolicy
  alias_rule :update?, :invite?, to: :edit?
  alias_rule :create?, :show?, :index?, to: :new?

  def new?
    true
  end

  def edit?
    user == record.owner || record.memberships.admin.where(user: user).exists?
  end

  def publish?
    user == record.owner || record.publishers.where(user: user).exists?
  end

  def destroy?
    user == record.owner
  end

  relation_scope { |relation| relation.joins(:members).where(memberships: { user_id: user.id }) }
end
