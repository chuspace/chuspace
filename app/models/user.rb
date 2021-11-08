# frozen_string_literal: true

class User < ApplicationRecord
  extend FriendlyId
  include Trackable
  has_person_name
  friendly_id :name, use: %i[history finders], slug_column: :username

  has_many :blogs, dependent: :delete_all
  has_many :articles, dependent: :delete_all, foreign_key: :author_id
  has_many :storages, dependent: :delete_all
  has_many :identities, dependent: :delete_all
  validates :email, :username, :first_name, :name, presence: true
  validates :username, uniqueness: true, length: { in: 1..39 }, format: { with: /\A^[a-z0-9]+(?:-[a-z0-9]+)*$\z/i }
  validates :email, uniqueness: true, email: true
  encrypts :email, deterministic: true, downcase: true

  AVATAR_VARIANTS = { xs: 32, sm: 48, md: 64, lg: 80, xl: 120, thumb: 150, profile: 250 }.freeze
  accepts_nested_attributes_for :identities

  def about_readme
    @about_readme ||= blogs.default.readme_html unless blogs.default.blank?
  end

  class << self
    def create_with_email_identity(email:)
      user = User.new(
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

  def enable_default_blogging
    ChuspaceAdapter.as_superuser.create_user(user: self)
    adapter = ChuspaceAdapter.as_superuser
    adapter.basic_auth = true
    adapter.sudo = username

    access_token = adapter.create_personal_access_token(user: self)
    storage = storages.create!(access_token: access_token, provider: :chuspace)

    storage.blogs.create!(
      user: self,
      name: username,
      default: true,
      visibility: :internal,
      **BlogFrameworkConfig.default.slice(:framework, :posts_folder, :drafts_folder, :assets_folder)
    )
  end

  def to_param
    username
  end
end
