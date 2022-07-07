#!/bin/bash
set -e

# Remove a potentially pre-existing server.pid for Rails.
rm -f /usr/src/app/tmp/pids/server.pid

echo "bundle install..."
bbundle check || (bundle install --without development test --jobs=4 --retry=3)

# Then exec the container's main process (what's set as CMD in the Dockerfile).
exec "$@"
