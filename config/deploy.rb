# deployment servers
role :app, "delta.peervoice.com"
role :web, "delta.peervoice.com"
role :db,  "delta.peervoice.com", :primary => true

# application name in source control
set :application_scm, :vault

# dynamic targets
set :target, ENV["TARGET"] || :default
load "config/targets/#{target}"

# basic deployment info, should not have to change
set :scm,         :git
set :repository,  "git@peervoice.com:rails/#{application_scm}.git"
set :deploy_to,   "/srv/app/#{application}"
set :user,        "app"
set :ssh_options, { :forward_agent => true }
set :conf_dir,    "/srv/conf/apps/#{application}"

# mongrel_cluster integration
#require 'mongrel_cluster/recipes'
set :mongrel_conf, "#{current_path}/config/mongrel_cluster.yml"

# overload run-state tasks for god
namespace :deploy do
  desc "Start the application using God"
  task :start do
    sudo %{god start rails-#{application}-app}
  end
  desc "Stop the application using God"
  task :stop do
    sudo %{god stop rails-#{application}-app}
  end
  desc "Restart the application using God"
  task :restart do
    sudo %{god restart rails-#{application}-app}
  end
end

# custom deploy tasks
namespace :peervoice do

  namespace :configure do
  
    desc "copy app-specific configuration files into place"
    task :application do
      run %{if [ -d #{conf_dir} ]; then cp -R #{conf_dir}/* #{release_path}/config/; fi}
      run %{cd #{release_path} && rake peervoice:configure:target}
    end
    
    desc "symlink production sqlite database into the appropriate place"
    task :sqlite do
      run %{mkdir -p #{shared_path}/db}
      run %{ln -nfs #{shared_path}/db/production.sqlite3 #{release_path}/db/production.sqlite3}
    end
  
  end
    
  namespace :mongrel do

    desc "set up god for these mongrels"
    task :god do
      god_conf = "/srv/conf/god/rails/#{application}.god"
      sudo %{/srv/util/mongrel-god/mongrel-god.rb "#{application}" "#{mongrel_conf}" "#{god_conf}"}
      sudo %{god load #{god_conf}}
    end
    
    desc "get an available port for this mongrel"
    task :port do
      run %{/srv/util/mongrel-port/mongrel-port.rb "#{application}" "#{mongrel_conf}.deploy" > "#{mongrel_conf}"}
    end
    
    desc "register this mongrel with nginx"
    task :nginx do
      sudo %{ln -sf "#{mongrel_conf}" "/etc/mongrel/#{application}.yml"}
      sudo %{ln -sf "#{mongrel_conf}" "/srv/conf/mongrel/#{application}.yml"}
      sudo %{/srv/util/mongrel-nginx/mongrel-nginx.rb "#{application}" "#{mongrel_conf}" "/srv/conf/sites/#{application}.site"}
      sudo %{god restart nginx}
    end

  end
end

after 'deploy:update_code', 'peervoice:configure:application'
after 'deploy:update_code', 'peervoice:configure:sqlite'
after 'deploy:symlink',     'peervoice:mongrel:port'
after 'deploy:symlink',     'peervoice:mongrel:god'
after 'deploy:symlink',     'peervoice:mongrel:nginx'
