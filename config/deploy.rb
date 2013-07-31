require 'bundler/capistrano'

set :application, "apihack"
set :repository,  "git@github.com:fstech/apihack.git"
set :deploy_to, "/var/www/apihack"
set :user, "hackkrk"

set :scm, :git
set :branch, "master"
set :ssh_options, { :forward_agent => true }
ssh_options[:keys] = ["#{ENV['HOME']}/.ssh/hackkrk-deploy.pem"]
set :use_sudo, false

role :app, "apihack.hackkrk.com"

after "deploy:restart", "delayed_job:restart", "deploy:cleanup"
after "deploy:update_code", "db:symlink", "db:migrate", "assets:precompile"

namespace :deploy do
  task :start do ; end
  task :stop do ; end
  task :restart, :roles => :app, :except => { :no_release => true } do
    run " touch #{File.join(current_path,'tmp','restart.txt')}"
  end
end

namespace :db do
  desc "Make symlink for database yaml" 
  task :symlink do
    run "ln -nfs #{shared_path}/config/database.yml #{release_path}/config/database.yml" 
  end

  desc "Migrate" 
  task :migrate do
    run "cd #{release_path}; RAILS_ENV=production bundle exec rake db:migrate" 
  end
end

namespace :assets do
  desc "Precompile assets" 
  task :precompile do
    run "cd #{release_path}; RAILS_ENV=production bundle exec rake assets:precompile" 
  end
end

namespace :delayed_job do
  desc "Restart delayed_job" 
  task :restart do
    run "sudo /usr/bin/sv restart /etc/sv/apihack-dj-*"
  end
end
