# frozen_string_literal: true
require 'json'
json ||= JSON.parse(`bundle exec rails terraform:run['output']`)

plugin 'git'
plugin 'env'
plugin 'bundler'
plugin 'rails'
plugin 'nodenv'
plugin 'puma'
plugin 'rbenv'
plugin './plugins/yarn.rb'

set application: 'chuspace'
set deploy_to: '/var/www/%{application}'
set nodenv_node_version: '16.13.0'
set nodenv_install_yarn: true
set git_url: 'git@github.com:chuspace/chuspace.git'
set git_branch: 'main'
set puma_port: 3000
set git_exclusions: %w[
  .tomo/
  spec/
  test/
]

set env_vars: {
  APP_REGION: :prompt,
  RACK_ENV: 'production',
  RAILS_ENV: 'production',
  RAILS_LOG_TO_STDOUT: '1',
  RAILS_SERVE_STATIC_FILES: '1',
  BOOTSNAP_CACHE_DIR: 'tmp/bootsnap-cache',
  DATABASE_URL: :prompt,
  DATABASE_REPLICA_URL: :prompt,
  RAILS_MASTER_KEY: :prompt,
  SECRET_KEY_BASE: :prompt,
  FATHOM_SITE_ID: :prompt,
  ASSET_HOST: 'https://assets.chuspace.com',
  AVATARS_CDN_HOST: 'https://avatars.chuspace.com',
  IMAGE_CDN_HOST: 'https://images.chuspace.com',
  SSL_CA_PATH: '/etc/ssl/certs/ca-certificates.crt',
  EXECJS_RUNTIME: 'Node'
}

environment :eu_west do
  json["aws_eu_west_servers"]["value"].each do |ip_address|
    host "deployer@#{ip_address}"
  end
end

environment :eu_north do
  json["aws_eu_north_servers"]["value"].each do |ip_address|
    host "deployer@#{ip_address}"
  end
end

environment :ap_east do
  json["aws_apac_east_servers"]["value"].each do |ip_address|
    host "deployer@#{ip_address}"
  end
end

environment :ap_south do
  json["aws_apac_south_servers"]["value"].each do |ip_address|
    host "deployer@#{ip_address}"
  end
end

environment :us_east do
  json["do_us_nyc_servers"]["value"].each do |ip_address|
    host "deployer@#{ip_address}"
  end
end

environment :us_west do
  json["do_us_sfo_servers"]["value"].each do |ip_address|
    host "deployer@#{ip_address}"
  end
end

environment :canada do
  json["do_us_tor_servers"]["value"].each do |ip_address|
    host "deployer@#{ip_address}"
  end
end

set linked_dirs: %w[
  .yarn/cache
  log
  node_modules
  public/assets
  public/packs
  tmp/cache
  tmp/pids
  tmp/sockets
]

setup do
  run 'env:setup'
  run 'core:setup_directories'
  run 'git:config'
  run 'git:clone'
  run 'git:create_release'
  run 'core:symlink_shared'
  run 'nodenv:install'
  run 'rbenv:install'
  run 'bundler:upgrade_bundler'
  run 'bundler:config'
  run 'bundler:install'
  run 'yarn:install'
  run 'bundler:install'
  run 'puma:setup_systemd'
end

deploy do
  run 'env:update'
  run 'git:create_release'
  run 'core:symlink_shared'
  run 'core:write_release_json'
  run 'bundler:install'
  run 'yarn:install'
  run 'rails:assets_precompile'
  run 'core:symlink_current'
  run 'puma:restart'
  run 'puma:check_active'
  run 'core:clean_releases'
  run 'bundler:clean'
  run 'core:log_revision'
end
# rubocop:enable Style/FormatStringToken
