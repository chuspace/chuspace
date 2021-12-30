# frozen_string_literal: true

class User < ApplicationRecord
  include Avatarable, Trackable
  extend FriendlyId

  friendly_id :username, use: :history, slug_column: :username

  has_person_name

  has_many :memberships, dependent: :destroy, inverse_of: :user
  has_many :identities, dependent: :destroy, inverse_of: :user
  has_many :blogs, through: :memberships, source: :blog
  has_many :owning_blogs, class_name: 'Blog', foreign_key: :owner_id, dependent: :destroy, inverse_of: :owner
  has_one  :personal_blog, -> { where(personal: true) }, class_name: 'Blog', foreign_key: :owner_id, inverse_of: :owner
  has_many :posts, foreign_key: :author_id, dependent: :destroy
  has_many :git_providers, dependent: :destroy

  validates :email, :username, :first_name, :name, presence: true
  validates :username, uniqueness: true, length: { in: 1..39 }, format: { with: /\A^[a-z0-9]+(?:-[a-z0-9]+)*$\z/i }
  validates :email, uniqueness: true, email: true
  encrypts  :email, deterministic: true, downcase: true

  after_create_commit :seed_git_providers

  class << self
    def build_with_email_identity(email_params)
      user = User.new(email_params)
      user.identities.build(uid: user.email, provider: :email)
      user
    end
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

  def seed_git_providers
    GitStorageConfig.new.to_h.each do |key, hash|
      git_providers.create(
        name: key,
        label: hash[:label],
        endpoint: hash[:endpoint],
        self_hosted: hash[:self_hosted]
      )
    end
  end
end
