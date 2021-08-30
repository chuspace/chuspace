# frozen_string_literal: true

class Storage < ApplicationRecord
  has_many :blogs, dependent: :delete_all
  belongs_to :user, optional: true
  encrypts :access_token, :endpoint

  validates :description, :provider, :access_token, presence: true
  validates :provider, uniqueness: { scope: :user_id, message: :one_provider_per_user }

  enum provider: GitStorageConfig.providers_enum

  def connected?
    true
    #  Add logic
  end

  def adapter
    @adapter ||= StorageAdapter.new(storage: self)
  end

  def provider
    super ? ActiveSupport::StringInquirer.new(super) : nil
  end

  delegate :chuspace?, to: :provider, allow_nil: true

  class << self
    def chuspace_adapter
      @chuspace_adapter ||= ChuspaceAdapter.new(**Rails.application.credentials.storage[:chuspace].slice(:endpoint, :access_token))
    end

    def external
      where.not(provider: GitStorageConfig.chuspace[:provider])
    end

    def chuspace
      find_by(provider: GitStorageConfig.chuspace[:provider])
    end

    def default
      external.find_by(default: true)
    end

    def default_or_chuspace
      default || chuspace
    end
  end
end
