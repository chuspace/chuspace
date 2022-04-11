# frozen_string_literal: true

def install
  remote.run "cd #{paths.release} && yarn install"
end
