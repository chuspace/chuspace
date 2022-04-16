# frozen_string_literal: true

class User < ApplicationRecord
  include Avatarable, Trackable
  include PgSearch::Model
  extend FriendlyId

  multisearchable against: %i[first_name last_name username email]
  pg_search_scope :search,
                  against: %i[first_name last_name username email],
                  using: {
                    tsearch: { prefix: true, negation: true }
                  }

  friendly_id :username, use: :history, slug_column: :username

  has_person_name

  has_many :memberships, dependent: :destroy, inverse_of: :user
  has_many :identities, dependent: :destroy, inverse_of: :user
  has_many :publications, through: :memberships, source: :publication
  has_many :owning_publications, class_name: 'Publication', foreign_key: :owner_id, dependent: :destroy, inverse_of: :owner
  has_one  :personal_publication, -> (user) { where(personal: true, permalink: user.username) }, class_name: 'Publication', foreign_key: :owner_id, inverse_of: :owner
  has_many :posts, foreign_key: :author_id, dependent: :destroy
  has_many :git_providers, dependent: :destroy

  validates :email, :username, :first_name, :name, presence: true
  validates :username, uniqueness: true, length: { in: 1..39 }, format: { with: /\A^[a-z0-9]+(?:-[a-z0-9]+)*$\z/i }
  validates :email, uniqueness: true, email: true
  encrypts  :email, deterministic: true, downcase: true

  after_create_commit :seed_git_providers, if: -> { ChuspaceConfig.new.app[:out_of_private_beta] }

  class << self
    def build_with_email_identity(email_params)
      user = User.new(email_params)
      user.identities.build(uid: user.email, provider: :email)
      user
    end
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

  def seed_git_providers
    data = GitStorageConfig.new.to_h.map do |key, config|
      {
        user_id: id,
        created_at: Time.current,
        updated_at: Time.current,
        **config
      }
    end

    GitProvider.upsert_all(data, returning: false, unique_by: :one_provider_per_user_index)
  end
end
