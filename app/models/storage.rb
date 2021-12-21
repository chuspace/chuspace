# frozen_string_literal: true

class Storage < ApplicationRecord
  has_many   :blogs, inverse_of: :storage
  belongs_to :user, optional: true

  encrypts :access_token, :endpoint

  validates :description, :provider, :endpoint, presence: true
  validates :access_token, presence: true, unless: :chuspace?
  validates :provider, uniqueness: { scope: :user_id, message: :one_provider_per_user }
  validates :default, uniqueness: { scope: :user_id, message: :one_default_storage_allowed }

  enum provider: GitStorageConfig.providers_enum

  before_validation :assign_endpoint, if: -> { chuspace? || !self_hosted? }
  before_validation :assign_description, if: :chuspace?
  before_create     :setup_chuspace_git_storage, if: :chuspace?
  before_destroy    :remove_chuspace_git_storage, if: :chuspace?

  delegate :chuspace?, to: :provider, allow_nil: true

  def to_param
    provider
  end

  class << self
    def external
      where.not(provider: chuspace_config[:provider])
    end

    def chuspace
      find_by(provider: chuspace_config[:provider])
    end

    def default
      external.find_by(default: true)
    end

    def default_or_chuspace
      default || chuspace
    end

    def chuspace_config
      GitStorageConfig.chuspace
    end

    def public_providers
      GitStorageConfig.external.map do |key, config|
        [key.humanize, key]
      end
    end

    def provider_scopes
      GitStorageConfig.defaults.each_with_object({}) do |(key, config), hash|
        hash[key] = config['scopes']
      end
    end
  end

  def external?
    !chuspace?
  end

  def self_hosted?
    provider_config[:self_hosted]
  end

  def label
    provider_config[:label]
  end

  def adapter
    StorageAdapter.new(storage: self)
  end

  def provider
    super ? ActiveSupport::StringInquirer.new(super) : nil
  end

  def provider_config
    GitStorageConfig.new.send(provider)
  end

  private

  def assign_endpoint
    self.endpoint = provider_config[:endpoint]
  end

  def assign_description
    self.description = provider_config[:description]
  end

  def setup_chuspace_git_storage
    ChuspaceAdapter.as_superuser.create_user(username: user.username, name: user.name, email: user.email)
    adapter = ChuspaceAdapter.as_superuser
    adapter.basic_auth = true
    adapter.sudo = user.username

    self.access_token = adapter.create_personal_access_token(username: user.username)
  rescue FaradayClient::Error
    ChuspaceAdapter.as_superuser.delete_user(username: user.username)
  end

  def remove_chuspace_git_storage
    ChuspaceAdapter.as_superuser.delete_user(username: user.username)
  end
end
