# frozen_string_literal: true

class Publication < ApplicationRecord
  extend FriendlyId
  include PgSearch::Model
  include Repoable, Iconable
  include AttrJson::Record
  include AttrJson::Record::QueryScopes
  include AttrJson::NestedAttributes

  attr_json_config(default_container_attribute: :settings, default_rails_attribute: true, default_accepts_nested_attributes: { reject_if: :all_blank })

  friendly_id :name, use: %i[slugged history], slug_column: :permalink
  multisearchable against: :name

  has_many :invites, dependent: :destroy, inverse_of: :publication
  has_many :memberships, dependent: :destroy, inverse_of: :publication
  has_many :members, through: :memberships, source: :user
  has_many :posts, dependent: :destroy, inverse_of: :publication

  belongs_to :owner, class_name: 'User'
  belongs_to :git_provider

  after_create :create_owning_membership

  validates :name, uniqueness: { scope: :owner_id }
  validates :name, :visibility, presence: true
  validate  :one_personal_publication_per_owner, on: :create

  acts_as_taggable_on :topics

  attr_json :repo, RepositorySetting.to_type, default: PublicationConfig.new.repo
  attr_json :front_matter, FrontMatterSetting.to_type, default: PublicationConfig.new.front_matter
  attr_json :content, PublicationSetting.to_type, default: PublicationConfig.new.settings

  scope :personal, -> { where(personal: true) }
  scope :except_personal, -> { where(personal: false) }

  enum visibility: PublicationConfig.to_enum, _suffix: true

  def visibility
    super ? ActiveSupport::StringInquirer.new(super) : nil
  end

  private

  def should_generate_new_friendly_id?
    name.blank? || name_changed?
  end

  def resolve_friendly_id_conflict(candidates)
    self.name = normalize_friendly_id(name) if name
  end

  def one_personal_publication_per_owner
    errors.add(:personal, :one_personal_publication_allowed) if personal? && owner.publications.personal.any?
  end

  def create_owning_membership
    memberships.create(user: owner, role: :owner)
  end
end
