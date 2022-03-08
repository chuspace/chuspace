# frozen_string_literal: true

class Invite < ApplicationRecord
  belongs_to :publication
  belongs_to :sender, class_name: 'User'

  validates :identifier, :role, presence: true
  validates :identifier, presence: true, email: true, if: -> { recipient.blank? }
  validate  :check_if_recipient_can_be_invited

  validates_uniqueness_of :identifier, scope: :publication_id, message: 'Already invited'
  validates_uniqueness_of :code

  after_create :send_email

  enum status: { pending: 'pending', accepted: 'accepted', expired: 'expired' }
  enum role: RolesConfig.invitable_enum

  has_secure_token :code

  def recipient
    @recipient ||= User.find_by(email: identifier) || User.find_by(username: identifier)
  end

  def recipient_email
    recipient.blank? ? identifier : recipient.email
  end

  private

  def check_if_recipient_can_be_invited
    errors.add(:identifier, 'Already a member') if publication.members.include?(recipient)
  end

  def send_email
    UserMailer.with(invitation: self).invite.deliver_later
  end
end
