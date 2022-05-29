# frozen_string_literal: true

module Git
  class Repository < ActiveType::Object
    attribute :id, :string
    attribute :fullname, :string
    attribute :name, :string
    attribute :owner, :string
    attribute :description, :string
    attribute :visibility, :string
    attribute :ssh_url, :string
    attribute :html_url, :string
    attribute :clone_url, :string
    attribute :temp_clone_token, :string
    attribute :default_branch, :string
    attribute :license_key, :string
    attribute :license_name, :string
    attribute :adapter, ApplicationAdapter

    def clone_path_with_token
      "https://#{owner}:#{temp_clone_token}@github.com/#{fullname}"
    end

    def tmp_clone
      `git clone #{clone_path_with_token} #{tmp_clone_path.to_s}` unless cloned?
      tmp_clone_path.to_s
    end

    def force_tmp_clone
      gc
      tmp_clone
    end

    alias force_tmp_clone tmp_clone

    def gc
      `rm -rf #{tmp_clone_path.to_s}`
      true
    end

    def cloned?
      tmp_clone_path.exist?
    end

    def tmp_clone_path
      Pathname.new("/tmp/#{fullname}")
    end
  end
end
