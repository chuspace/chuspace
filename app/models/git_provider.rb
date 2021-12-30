class GitProvider < ApplicationRecord
  belongs_to :user
  encrypts :access_token, :refresh_access_token, :endpoint

  validates :name, :label, presence: true
  validates :name, uniqueness: { scope: :user_id }
  validates :refresh_access_token, :expires_at, presence: true, if: :access_token

  enum name: {
    github: 'github',
    gitlab: 'gitlab'
  }

  def connected?
    access_token.present? && expires_at > Time.current
  end

  def users
    adapter.users
  end

  def adapter
    @adapter ||= GitAdapter.new(git_provider: self)
  end

  def to_param
    name
  end
end
