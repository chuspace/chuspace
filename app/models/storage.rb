# frozen_string_literal: true

class Storage < ApplicationRecord
  has_many :blogs, dependent: :delete_all
  belongs_to :user, optional: true
  encrypts :access_token, :endpoint

  validates :description, :provider, :access_token, presence: true
  validates :provider, uniqueness: { scope: :user_id, message: :one_provider_per_user }

  enum provider: GitStorageConfig.providers_enum

  before_save :add_provider_defaults, unless: :chuspace?
  delegate :chuspace?, to: :provider, allow_nil: true
  delegate :repositories, to: :adapter

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

  def adapter
    @adapter ||= StorageAdapter.new(storage: self)
  end

  def provider
    super ? ActiveSupport::StringInquirer.new(super) : nil
  end

  def provider_user
    @provider_user ||= adapter.user
  end

  def provider_config
    @provider_config ||= GitStorageConfig.new.send(provider)
  end

  private

  def add_provider_defaults
    self.assign_attributes(provider_config.slice(:description, :endpoint))
    self.provider_user_id = adapter.user.id
  end
end
