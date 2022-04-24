# frozen_string_literal: true

class CollaborationSession < ApplicationRecord
  belongs_to :publication
  has_many   :members, class_name: 'CollaborationSessionMember', dependent: :delete_all
  has_one    :creator, -> { where(creator: true) }, class_name: 'CollaborationSessionMember'

  enum status: ChuspaceConfig.new.collaboration_session[:statuses]

  validates :publication_id, uniqueness: { scope: %i[blob_path number] }

  before_validation :assign_next_number, on: :create

  def decoded_content
    $ydoc.parse(ydoc: current_ydoc) if current_ydoc&.present?
  end

  def editor_attrs(user:)
    {
      channel: 'CollaborationSessionChannel',
      id: Turbo.signed_stream_verifier.generate(id),
      user: {
        id: user.id,
        username: user.username,
        name: user.name,
        avatar_url: user.avatar_url
      },
      ydoc: current_ydoc || initial_ydoc
    }.to_json
  end

  def end
    update(status: :closed)
  end

  private

  def assign_next_number
    self.number = (publication.collaboration_sessions.maximum(:number) || 0) + 1
    self.status = ChuspaceConfig.new.collaboration_session[:default_status]
  end
end
