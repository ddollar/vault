# deployment servers
role :app, "delta.peervoice.com"
role :web, "delta.peervoice.com"
role :db,  "delta.peervoice.com", :primary => true

# application name in source control
set :application_scm, :generic

# dynamic targets
set :target, ENV["TARGET"] || :default
load "config/targets/#{target}"

# basic deployment info, should not have to change
set :scm,         :git
set :repository,  "git@peervoice.com:#{application_scm}.git"
set :deploy_to,   "/srv/app/#{application}"
set :user,        "app"
set :ssh_options, { :forward_agent => true }
set :conf_dir,    "/srv/conf/apps/#{application}"

# mongrel_cluster integration
require 'mongrel_cluster/recipes'
set :mongrel_conf, "#{current_path}/config/mongrel_cluster.yml"

# custom deploy tasks
namespace :peervoice do

  namespace :configure do
  
    desc "copy app-specific configuration files into place"
    task :application do
      run %{if [ -d #{conf_dir} ]; then cp -R #{conf_dir}/* #{current_path}/config/; fi}
    end
    
  end
    
  namespace :mongrel do

    desc "get an available port for this mongrel"
    task :port do
      run %{/srv/util/mongrel_port/mongrel_port.rb "#{application}" "#{mongrel_conf}.dist" > "#{mongrel_conf}"}
    end
    
    desc "register this mongrel with nginx"
    task :nginx do
      sudo %{ln -sf "#{mongrel_conf}" "/etc/mongrel/#{application}.yml"}
      sudo %{/srv/util/mongrel_nginx/mongrel_nginx.rb "#{application}" "#{mongrel_conf}" "/srv/conf/sites/#{application}.site"}
      sudo %{/etc/init.d/nginx restart}
    end

  end
end

after 'deploy:symlink', 'peervoice:configure:application'
after 'deploy:symlink', 'peervoice:mongrel:port'
after 'deploy:symlink', 'peervoice:mongrel:nginx'
