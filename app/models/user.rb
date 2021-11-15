# frozen_string_literal: true

class User < ApplicationRecord
  include Trackable
  extend FriendlyId
  friendly_id :username, use: :history, slug_column: :username

  has_person_name

  has_many :blogs, dependent: :delete_all
  has_many :storages, dependent: :delete_all
  has_many :identities, dependent: :delete_all
  validates :email, :username, :first_name, :name, presence: true
  validates :username, uniqueness: true, length: { in: 1..39 }, format: { with: /\A^[a-z0-9]+(?:-[a-z0-9]+)*$\z/i }
  validates :email, uniqueness: true, email: true
  encrypts :email, deterministic: true, downcase: true

  AVATAR_VARIANTS = { xs: 32, sm: 48, md: 64, lg: 80, xl: 120, thumb: 150, profile: 250 }.freeze
  accepts_nested_attributes_for :identities

  def about_readme
    @about_readme ||= blogs.default.readme unless blogs.default.blank?
  end

  class << self
    def create_with_email_identity(email:)
      user = User.
      new(
        name: email.split('@').first.humanize,
        username: email.to_slug.normalize.to_s,
        email: email
      )

      user.identities.build(
        uid: email,
        magic_auth_token_expires_at: Identity::MAGIC_AUTH_TOKEN_LIFE.minutes.from_now,
        provider: :email
      )

      user
    end
  end

  def avatar_url(variant: :xs)
    size = AVATAR_VARIANTS[variant] || fail(AvatarVariantNotFound, 'Avatar variant not found')
    gravatar_url(variant: variant)
  end

  def gravatar_url(variant: :xs)
    size = AVATAR_VARIANTS[variant] || fail(AvatarVariantNotFound, 'Avatar variant not found')
    gravatar_id = Digest::MD5.hexdigest(email)
    "//secure.gravatar.com/avatar/#{gravatar_id}?d=identicon&s=#{size}"
  end

  private

  def should_generate_new_friendly_id?
    username.blank? || username_changed?
  end

  def resolve_friendly_id_conflict(candidates)
    self.username = normalize_friendly_id(username)
  end
end
