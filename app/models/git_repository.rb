# frozen_string_literal: true

class GitRepository
  include StoreModel::Model

  attribute :id, :integer
  attribute :fullname, :string
  attribute :description, :string
  attribute :name, :string
  attribute :owner, :string
  attribute :ssh_url, :string
  attribute :html_url, :string
  attribute :visibility, :string
  attribute :folders, :string
  attribute :default_branch, :string, default: :main
end
