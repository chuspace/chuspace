# frozen_string_literal: true

class Storage < ApplicationRecord
  belongs_to :user
  encrypts :access_token, :endpoint

  validates :description, :provider, :access_token, :system, presence: true
  validates :provider, uniqueness: { scope: :user_id, message: :one_provider_per_user }

  enum provider: GitStorageConfig.providers_enum

  before_validation :set_endpoint, on: :create

  def connected?
    true
    #  Add logic
  end

  def adapter
    @adapter ||= StorageAdapter.new(storage_id: id)
  end

  private

  def set_endpoint
    self.endpoint ||= GitStorageConfig.new.send(provider).dig(:endpoint)
  end
end
