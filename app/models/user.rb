# frozen_string_literal: true

class User < ApplicationRecord
  include IdentityCache
  include Avatarable, Trackable, CachedSlugs
  include PgSearch::Model
  extend FriendlyId

  multisearchable against: %i[first_name last_name username]
  pg_search_scope :search,
                  against: %i[first_name last_name username],
                  using: {
                    tsearch: { prefix: true, negation: true }
                  }

  friendly_id :username, use: %i[slugged history], slug_column: :username

  has_person_name

  has_many :memberships, dependent: :destroy, inverse_of: :user
  has_many :identities, dependent: :destroy, inverse_of: :user
  has_many :email_identities, -> { where(identities: { provider: :email }) }, class_name: 'Identity', inverse_of: :user
  has_many :publications, through: :memberships, source: :publication
  has_many :owning_publications, class_name: 'Publication', foreign_key: :owner_id, dependent: :destroy, inverse_of: :owner
  has_one  :personal_publication, -> { where(personal: true) }, class_name: 'Publication', foreign_key: :owner_id, inverse_of: :owner
  has_many :posts, foreign_key: :author_id, dependent: :destroy, inverse_of: :author
  has_many :git_providers, dependent: :destroy, inverse_of: :user

  cache_has_many :owning_publications, embed: true
  cache_has_many :posts, embed: true

  cache_has_one :personal_publication, embed: true

  validates :email, :username, :first_name, :name, presence: true
  validates :username, uniqueness: true, length: { in: 1..39 }, format: { with: /\A^[a-z0-9]+(?:-[a-z0-9]+)*$\z/i }
  validates :email, uniqueness: true, email: true
  encrypts  :email, deterministic: true, downcase: true

  after_create_commit -> { SeedGitProvidersJob.perform_later(user: self) }
  after_update_commit -> { personal_publication.save }, if: -> { personal_publication.present? && username_previously_changed? }

  class << self
    def build_with_email_identity(email_params)
      user = User.new(email_params)
      user.identities.build(uid: user.email, provider: :email)
      user
    end
  end

  def send_welcome_email
    UserMailer.with(user: self).welcome_email.deliver_later
  end

  private

  def unset_slug_if_invalid
    self.username = username
  end

  def should_generate_new_friendly_id?
    username.blank? || username_changed?
  end

  def resolve_friendly_id_conflict(candidates)
    self.username = username
  end
end
