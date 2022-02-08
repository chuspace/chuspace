# frozen_string_literal: true

module Git
  class Committer < Author
    def self.chuspace
      Committer.new(GitConfig.new.committer)
    end
  end
end
