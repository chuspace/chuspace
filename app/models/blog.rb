# frozen_string_literal: true

class Blog < ApplicationRecord
  extend FriendlyId
  friendly_id :name, use: %i[slugged history], slug_column: :name

  has_one :repository, dependent: :destroy, autosave: true
  has_many :drafts, through: :repository, source: :blobs
  has_many :articles, dependent: :destroy
  belongs_to :user
  belongs_to :storage
  belongs_to :template, optional: true, class_name: 'BlogTemplate'

  validates :name, uniqueness: { scope: :user_id }
  validates_presence_of :template_id, if: -> { storage.chuspace? }
  validates_presence_of :name, :visibility
  validate :one_default_blog_allowed, on: :create
  accepts_nested_attributes_for :repository

  enum visibility: {
    private: 'private',
    public: 'public',
    internal: 'internal'
  }, _suffix: true

  scope :default, -> { find_by(default: true) }

  def visibility
    super ? ActiveSupport::StringInquirer.new(super) : nil
  end

  private

  def one_default_blog_allowed
    errors.add(:default, :one_default_blog_allowed) if default? && user.blogs.default.present?
  end

  def unset_slug_if_invalid
    self.name = normalize_friendly_id(name)
  end

  def should_generate_new_friendly_id?
    name.blank? || name_changed?
  end

  def resolve_friendly_id_conflict(candidates)
    self.name = normalize_friendly_id(name)
  end
end
