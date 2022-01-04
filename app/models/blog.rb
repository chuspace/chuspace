# frozen_string_literal: true

class Blog < ApplicationRecord
  extend FriendlyId
  include Repoable, Iconable

  friendly_id :name, use: %i[slugged history], slug_column: :permalink

  has_many :memberships, dependent: :destroy, inverse_of: :blog
  has_many :members, through: :memberships, source: :user
  has_many :posts, dependent: :destroy, inverse_of: :blog

  belongs_to :owner, class_name: 'User'
  belongs_to :git_provider

  validates :name, uniqueness: { scope: :owner_id }
  validates :name, :visibility, presence: true
  validate  :one_personal_blog_per_owner

  has_rich_text :readme

  acts_as_taggable_on :topics

  scope :personal, -> { where(personal: true) }
  scope :except_personal, -> { where(personal: false) }

  accepts_nested_attributes_for :members

  enum visibility: {
    private: 'private',
    public: 'public',
    subscriber: 'subscriber'
  }, _suffix: true

  def visibility
    super ? ActiveSupport::StringInquirer.new(super) : nil
  end

  def readme_html
    MarkdownRenderer.new.render(CommonMarker.render_doc(readme.to_plain_text)).html_safe
  end

  private

  def should_generate_new_friendly_id?
    name.blank? || name_changed?
  end

  def resolve_friendly_id_conflict(candidates)
    self.name = normalize_friendly_id(name) if name
  end

  def one_personal_blog_per_owner
    errors.add(:personal, :one_personal_blog_allowed) if personal? && owner.blogs.personal.any?
  end
end
