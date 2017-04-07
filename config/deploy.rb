# config valid only for current version of Capistrano
lock '3.8.0'

server 'tcpsnitch.org', roles: %w{app web db}

set :application, 'tcpsnitch_web'
set :app_fullname, "#{fetch(:application)}_#{fetch(:stage)}"
set :deploy_to, "~/#{fetch(:app_fullname)}"

set :repo_url, 'git@github.com:GregoryVds/tcpsnitch_web.git'
set :rbenv_ruby, '2.3.3'
set :pg_user, 'gvanderschueren'
set :pg_database, "#{fetch(:app_fullname)}"

set :ssh_options, {
  port: 143,
  user: 'gvanderschueren'
}

set :pty, false

set :sidekiq_env, fetch(:rack_env, fetch(:rails_env, fetch(:stage)))


append :linked_dirs, "public/uploads"

# Default value for :linked_files is []
# append :linked_files, "config/database.yml", "config/secrets.yml"

# Default value for linked_dirs is []

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for keep_releases is 5
# set :keep_releases, 5
