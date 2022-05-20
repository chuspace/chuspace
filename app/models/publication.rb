# frozen_string_literal: true

class Publication < ApplicationRecord
  extend FriendlyId
  include PgSearch::Model
  include Iconable, Metatagable
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
  has_many :images, dependent: :destroy, inverse_of: :publication
  has_many :readme_images, ->(publication) { where(draft_blob_path: publication.repository.readme_path) }, class_name: 'Image', dependent: :destroy, inverse_of: :publication
  has_one  :repository, dependent: :destroy, inverse_of: :publication, required: true

  belongs_to :owner, class_name: 'User'
  belongs_to :git_provider

  before_save  :set_permalink_to_owner_username, if: :personal?
  after_create :create_owning_membership

  validates :name, presence: true, length: { in: 1..80 }
  validates :name, :visibility, presence: true
  validate  :one_personal_publication_per_owner, on: :create

  acts_as_taggable_on :topics
  accepts_nested_attributes_for :repository, allow_destroy: true

  attr_json :front_matter, FrontMatterSetting.to_type, default: PublicationConfig.new.front_matter
  attr_json :content, PublicationContentSetting.to_type, default: PublicationConfig.new.settings

  scope :personal, -> { where(personal: true) }
  scope :except_personal, -> { where(personal: false) }

  enum visibility: PublicationConfig.to_enum, _suffix: true

  delegate :readme, :readme_html, to: :repository

  def gravatar_url(variant: :thumb)
    personal? ? owner.gravatar_url(variant: variant) : nil
  end

  def icon
    if personal?
      owner.avatar
    else
      super
    end
  end

  def initials
    personal? ? owner.name.initials : name.first(2).upcase
  end

  def name
    personal? ? owner.name : super
  end

  def visibility
    super ? ActiveSupport::StringInquirer.new(super) : nil
  end

  private

  def create_owning_membership
    memberships.create(user: owner, role: :owner)
  end

  def set_permalink_to_owner_username
    self.permalink = owner.username
  end

  def should_generate_new_friendly_id?
    name.blank? || name_changed?
  end

  def one_personal_publication_per_owner
    errors.add(:personal, :one_personal_publication_allowed) if personal? && owner.publications.personal.any?
  end
end
