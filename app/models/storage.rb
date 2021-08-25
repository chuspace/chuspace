# frozen_string_literal: true

class Storage < ApplicationRecord
  belongs_to :user, optional: true
  encrypts :access_token, :endpoint

  validates :description, :provider, :access_token, :system, presence: true
  validates :provider, uniqueness: { scope: :user_id, message: :one_provider_per_user }
  validate :one_system_storage_allowed, :one_default_storage_allowed

  enum provider: GitStorageConfig.providers_enum

  before_validation :set_endpoint, on: :create
  scope :system, -> { find_by(system: true) }
  scope :default, -> { find_by(default: true) }

  def connected?
    true
    #  Add logic
  end

  def adapter
    @adapter ||= StorageAdapter.new(storage_id: id)
  end

  def provider_name
    system? ? 'Chuspace' : storage.provider.humanize
  end

  private

  def set_endpoint
    self.endpoint ||= GitStorageConfig.new.send(provider).dig(:endpoint)
  end

  def one_system_storage_allowed
    errors.add(:base, :one_system_storage_allowed) if user.storages.where(system: true).count > 1
  end

  def one_default_storage_allowed
    errors.add(:base, :one_default_storage_allowed) if user.storages.where(default: true).count > 1
  end
end
