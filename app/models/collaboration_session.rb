# frozen_string_literal: true

class CollaborationSession < ApplicationRecord
  belongs_to :publication
  has_many   :members, class_name: 'CollaborationSessionMember', dependent: :delete_all
  has_one    :creator, -> { where(creator: true) }, class_name: 'CollaborationSessionMember'

  validates :publication_id, uniqueness: { scope: %i[blob_path number] }

  before_validation :assign_next_number, on: :create

  class << self
    def active
      where(active: true)
    end
  end

  def editor_attrs(user:)
    {
      channel: 'CollaborationSessionChannel',
      id: Turbo.signed_stream_verifier.generate(id),
      user: {
        id: user.id,
        username: user.username,
        name: user.name
      },
      ydoc: current_ydoc || initial_ydoc
    }.to_json
  end

  private

  def assign_next_number
    self.active = true
    self.number = (publication.collaboration_sessions.maximum(:number) || 0) + 1
  end
end
