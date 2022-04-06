def install
  remote.run "cd #{paths.release} && yarn install"
end
