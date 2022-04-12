# frozen_string_literal: true

plugin 'git'
plugin 'env'
plugin 'bundler'
plugin 'rails'
plugin 'nodenv'
plugin 'puma'
plugin 'rbenv'
plugin 'good_job'
plugin './plugins/yarn.rb'

# Primary region - Ireland
host 'deployer@63.35.200.43'

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
  REGION: 'Ireland',
  RACK_ENV: 'production',
  RAILS_ENV: 'production',
  RAILS_LOG_TO_STDOUT: '1',
  RAILS_SERVE_STATIC_FILES: '1',
  BOOTSNAP_CACHE_DIR: 'tmp/bootsnap-cache',
  DATABASE_URL: :prompt,
  REDIS_URL: :prompt,
  EXECJS_RUNTIME: 'Node',
  OUT_OF_PRIVATE_BETA: :prompt,
  RAILS_MASTER_KEY: :prompt
}
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
  run 'rails:db_create'
  run 'rails:db_schema_load'
  run 'rails:db_seed'
  run 'good_job:setup_systemd'
  run 'puma:setup_systemd'
end

deploy do
  run 'env:update'
  run 'git:create_release'
  run 'core:symlink_shared'
  run 'core:write_release_json'
  run 'bundler:install'
  run 'yarn:install'
  run 'rails:db_migrate'
  run 'rails:db_seed'
  run 'rails:assets_precompile'
  run 'core:symlink_current'
  run 'good_job:restart'
  run 'puma:restart'
  run 'puma:check_active'
  run 'core:clean_releases'
  run 'bundler:clean'
  run 'core:log_revision'
end
# rubocop:enable Style/FormatStringToken
