# frozen_string_literal: true

class User < ApplicationRecord
  include Trackable
  extend FriendlyId

  friendly_id :name, use: %i[slugged history finders], slug_column: :username

  has_one_attached :avatar
  has_many :blogs, dependent: :delete_all
  has_many :storages, dependent: :delete_all
  has_many :identities, dependent: :delete_all

  after_create_commit :create_internal_storage

  encrypts :email
  blind_index :email, slow: true

  enum onboarding_status: {
    profile: 'profile',
    storage: 'storage',
    blog: 'blog',
    follow: 'follow',
    complete: 'complete'
  }, _prefix: true

  AVATAR_VARIANTS = { xs: 32, sm: 48, md: 64, lg: 80, xl: 120, thumb: 150, profile: 250 }.freeze

  def onboarded?
    onboarding_status_complete?
  end

  def avatar_url(variant: :lg)
    size = AVATAR_VARIANTS[variant] || fail(AvatarVariantNotFound, 'Avatar variant not found')
    avatar.variant(resize_to_fit: [size, size])&.processed&.url || gravatar_url
  end

  def gravatar_url(variant: :xs)
    size = AVATAR_VARIANTS[variant] || fail(AvatarVariantNotFound, 'Avatar variant not found')
    gravatar_id = Digest::MD5.hexdigest(email)
    "//secure.gravatar.com/avatar/#{gravatar_id}?d=identicon&s=#{size}"
  end

  private

  def create_internal_storage
    storages.create!(Rails.application.credentials.storage[:chuspace])
  end
end
