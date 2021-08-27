# frozen_string_literal: true

class Storage < ApplicationRecord
  INTERNAL = :chuspace

  has_many :blogs, dependent: :delete_all
  belongs_to :user, optional: true
  encrypts :access_token, :endpoint

  validates :description, :provider, :access_token, presence: true
  validates :provider, uniqueness: { scope: :user_id, message: :one_provider_per_user }

  enum provider: GitStorageConfig.providers_enum

  before_validation :set_endpoint, on: :create
  before_create :create_internal_storage_user, if: :internal?
  after_create_commit :create_default_blog_for_internal_storage_user, if: :internal?
  after_destroy_commit :deactivate_internal_storage_user, if: :internal?

  scope :internal, -> { find_by(provider: :chuspace) }

  def connected?
    true
    #  Add logic
  end

  def adapter
    @adapter ||= StorageAdapter.new(storage: self)
  end

  def internal?
    provider.to_sym == INTERNAL
  end

  def self.default_or_internal
    default || internal
  end

  def self.default
    where.not(provider: :chuspace).find_by(default: true)
  end

  def provider_user
    @provider_user ||= adapter.user(id: provider_user_id)
  end

  private

  def set_endpoint
    self.endpoint ||= GitStorageConfig.new.send(provider).dig(:endpoint)
  end

  def create_default_blog_for_internal_storage_user
    blogs.create!(
      user: user,
      name: "#{user.name} blog",
      git_repo_name: 'blog',
      default: true
    )
  end

  def create_internal_storage_user
    storage_user = adapter.create_user(**user.slice(:name, :email, :username).symbolize_keys)
    self.provider_user_id = storage_user.id
  end

  def deactivate_internal_storage_user
    adapter.deactivate_user(**user.slice(:name, :email, :username).symbolize_keys)
  end
end
