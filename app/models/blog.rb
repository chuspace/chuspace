# frozen_string_literal: true

class Blog < ApplicationRecord
  include Repoable
  extend FriendlyId

  friendly_id :name, use: %i[slugged history], slug_column: :permalink

  has_many :members, class_name: 'Membership', dependent: :destroy, inverse_of: :blog
  has_many :posts, dependent: :destroy, inverse_of: :blog

  belongs_to :owner, class_name: 'User'
  belongs_to :storage
  belongs_to :template, optional: true, class_name: 'BlogTemplate'

  validates :name, uniqueness: { scope: :owner_id }

  validates_presence_of :template_id, if: -> { storage&.chuspace? }
  validates_presence_of :name, :visibility

  has_rich_text :readme

  acts_as_taggable_on :topics

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

  def parsed_readme
    MarkdownContent.new(content: readme.to_plain_text)
  end

  private

  def should_generate_new_friendly_id?
    name.blank? || name_changed?
  end

  def resolve_friendly_id_conflict(candidates)
    self.name = normalize_friendly_id(name) if name
  end
end
