# frozen_string_literal: true

class Invite < ApplicationRecord
  belongs_to :blog
  belongs_to :sender, class_name: 'User'

  validates :identifier, :role, presence: true
  validates :identifier, presence: true, email: true, if: -> { recipient.blank? }
  validate  :check_if_recipient_can_be_invited

  validates_uniqueness_of :identifier, scope: :publication_id
  validates_uniqueness_of :code

  after_create :send_email

  enum status: { pending: 'pending', accepted: 'accepted', expired: 'expired' }
  enum role: RolesConfig.to_enum

  has_secure_token :code

  def recipient
    @recipient ||= User.find_by_email(identifier)
  end

  def recipient_email
    recipient.blank? ? identifier : recipient.email
  end

  private

  def check_if_recipient_can_be_invited
    errors.add(:identifier, 'Already a member') if blog.members.include?(recipient)
  end

  def send_email
    UserMailer.with(invitation: self).invite.deliver_later
  end
end
