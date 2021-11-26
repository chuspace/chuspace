# frozen_string_literal: true

class User < ApplicationRecord
  include Trackable
  extend FriendlyId

  AVATAR_VARIANTS = {
    xs: 32,
    sm: 48,
    md: 64,
    lg: 80,
    xl: 120,
    thumb: 150,
    profile: 250
  }.freeze

  friendly_id :username, use: :history, slug_column: :username

  has_person_name

  has_many :memberships, dependent: :delete_all, inverse_of: :user
  has_many :blogs, -> { where(personal: false) }, through: :memberships, source: :blog
  has_many :storages, -> { where.not(provider: ::Storage.chuspace_config['provider']) }, dependent: :delete_all, inverse_of: :user
  has_many :identities, dependent: :delete_all, inverse_of: :user
  has_many :blog_templates, dependent: :delete_all, foreign_key: 'author_id', inverse_of: :author
  has_many :drafts, through: :personal_blog, source: :drafts, dependent: :delete_all
  has_many :articles, through: :personal_blog, source: :articles, dependent: :delete_all
  has_one  :personal_blog, -> { where(personal: true) }, class_name: 'Blog', foreign_key: :owner_id, dependent: :destroy, inverse_of: :owner
  has_one  :chuspace_storage, -> { where(provider: ::Storage.chuspace_config['provider']) }, class_name: 'Storage', dependent: :destroy, inverse_of: :user

  validates :email, :username, :first_name, :name, presence: true
  validates :username, uniqueness: true, length: { in: 1..39 }, format: { with: /\A^[a-z0-9]+(?:-[a-z0-9]+)*$\z/i }
  validates :email, uniqueness: true, email: true
  encrypts  :email, deterministic: true, downcase: true

  accepts_nested_attributes_for :identities

  class << self
    def create_with_email_identity(email:)
      user = User.
      new(
        name: email.split('@').first.humanize,
        username: email.to_slug.normalize.to_s,
        email: email
      )

      user.identities.build(uid: email, provider: :email)
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

  def unset_slug_if_invalid
    self.username = normalize_friendly_id(username)
  end

  def should_generate_new_friendly_id?
    username.blank? || username_changed?
  end

  def resolve_friendly_id_conflict(candidates)
    self.username = normalize_friendly_id(username)
  end
end
