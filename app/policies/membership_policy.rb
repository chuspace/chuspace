# frozen_string_literal: true

class MembershipPolicy < ApplicationPolicy
  alias_rule :update?, :create?, :show?, :new?, :destroy?, to: :edit?
  delegate :publication, to: :record

  def index?
    true
  end

  def edit?
    owner? || publication.memberships.admins.where(user: user).exists?
  end

  private

  def owner?
    user == publication.owner
  end
end
