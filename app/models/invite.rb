# frozen_string_literal: true

class Invite < ApplicationRecord
  belongs_to :publication
  belongs_to :sender, class_name: 'User'

  validates :identifier, :role, presence: true
  validates :identifier, presence: true, email: true, if: -> { recipient.blank? }
  validate  :check_if_recipient_can_be_invited, on: :create

  validates_uniqueness_of :identifier, scope: :publication_id, message: 'Already invited'
  validates_uniqueness_of :code

  after_create_commit :send_email

  enum status: { pending: 'pending', joined: 'joined', expired: 'expired' }
  enum role: RolesConfig.invitable_enum

  has_secure_token :code

  def recipient_name
    recipient.present? ? recipient.name : recipient_email.split('@').first
  end

  def recipient
    @recipient ||= User.find_by(email: identifier) || User.find_by(username: identifier)
  end

  def recipient_email
    recipient.blank? ? identifier : recipient.email
  end

  def send_email(resend: false)
    user.regenerate_code if resend
    UserMailer.with(invitation: self).invite_email.deliver_later
  end

  def accept!
    joined!
    regenerate_code
    publication.memberships.create(role: role, user: recipient)
  end

  def to_param
    code
  end

  private

  def check_if_recipient_can_be_invited
    errors.add(:identifier, 'Already a member') if publication.members.include?(recipient)
  end
end
