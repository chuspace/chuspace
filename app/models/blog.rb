# frozen_string_literal: true

class Blog < ApplicationRecord
  belongs_to :user
  attr_accessor :name, :description, :private, :owner, :type
  validates_presence_of :git_repo_name, :posts_folder, :drafts_folder, :assets_folder

  enum git_provider: {
    github: 'github',
    gitlab: 'gitlab',
    bitbucket: 'bitbucket'
  }, _suffix: true

  delegate :name, :description, :full_name, :private, :owner, to: :repo, allow_nil: true

  def repo
    @repo ||= github_client.repo(git_repo_name) if git_repo_name.present?
  end

  def write_post(name:, body:)
    github_client.create_contents(
      git_repo_name,
      "#{posts_folder}/#{name}",
      'Adding content',
      body
    )
  end

  private

  def github_client
    @github_client ||= Octokit::Client.new(access_token: user&.token)
  end
end
