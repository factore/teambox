require "bundler/capistrano"

default_run_options[:pty] = true
set :application, "teambox" # The name of the application
set :repository,  "git@github.com:factore/teambox.git" # Path to the Git Repo
set :scm, "git"
set :scm_passphrase, "9shwartz90005"
set :user, "deploy"
set :deploy_via, :remote_cache

set :deploy_to, "/var/apps/#{application}"

role :app, "app1.factore.ca", "app2.factore.ca", "metal1.factore.ca", "metal2.factore.ca"
role :db, "app1.factore.ca", :primary => true

after("deploy:update_code") { run "cd #{current_release}; cp config/database.yml.template config/database.yml" }
# Uncomment this line if the app uses ferret_server
# after("deploy:symlink") { run "chmod +rx #{current_path}/script/ferret_server" }
after("deploy:restart", "deploy:expire_cache")


# Clean up!
set :use_sudo, false
set :keep_releases, 2
after "deploy", "deploy:cleanup"
after "deploy:migrate", "deploy:cleanup"


# Passenger Stuff and Cache Expiry
namespace :deploy do
  desc "Restarting mod_rails with restart.txt"
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "touch #{current_path}/tmp/restart.txt"
  end
 
  [:start, :stop].each do |t|
    desc "#{t} task is a no-op with mod_rails"
    task t, :roles => :app do ; end
  end
  
  desc "Expire the cache"
  task :expire_cache, :roles => :db do
    run "cd /var/apps/#{application}/current; rake forge:expire_cache RAILS_ENV=production;"
  end
  
  desc "Deploy Forge"
  task :deploy_forge, :roles => :db do
    run "cd #{current_release}; rake forge:deploy RAILS_ENV=production PASSWORD=#{ENV['PASSWORD']}"
  end
end