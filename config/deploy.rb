# config valid only for current version of Capistrano
lock '3.4.0'

set :application, 'goldenseal'
set :repo_url, 'https://github.com/wulib-wustl-edu/goldenseal.git'
set :passenger_restart_with_touch, true
ask :branch, `git rev-parse --abbrev-ref HEAD`.chomp
set :deploy_to, '/opt/goldenseal'

# Default value for :scm is :git
# set :scm, :git

# Default value for :format is :pretty
# set :format, :pretty

# Default value for :log_level is :debug
set :log_level, :debug

# Default value for :pty is false
# set :pty, true

# Default value for :linked_files is []
set :linked_files, fetch(:linked_files, []).push('config/blacklight.yml', 'config/database.yml', 'config/fedora.yml', 'config/redis.yml', 'config/resque-pool.yml', 'config/ldap.yml', 'config/secrets.yml', 'config/solr.yml')

# Default value for linked_dirs is []
set :linked_dirs, fetch(:linked_dirs, []).push('log', 'tmp', 'vendor/bundle', 'public/system')

# settings for resque-pool restart
set :resque_stderr_log, "#{shared_path}/log/resque-pool.stderr.log"
set :resque_stdout_log, "#{shared_path}/log/resque-pool.stdout.log"
set :resque_kill_signal, "QUIT"

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for keep_releases is 5
# set :keep_releases, 5

require "resque"

namespace :deploy do
  before :restart, "resque:pool:stop"

  after :restart, :clear_cache do
    on roles(:web), in: :groups, limit: 3, wait: 10 do
      # Here we can do anything such as:
      # within release_path do
      #   execute :rake, 'cache:clear'
      # end
    end
  end

  after :clear_cache, "resque:pool:start"
end
