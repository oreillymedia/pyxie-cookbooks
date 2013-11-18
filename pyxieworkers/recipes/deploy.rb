ENV['LANGUAGE'] = ENV['LANG'] = ENV['LC_ALL'] = "en_US.UTF-8"

include_recipe "apt"

include_recipe "redisio::install"
include_recipe "redisio::enable"

#******************************************************************************************
#  Set up docker
#******************************************************************************************

execute "install_docker" do
  command "curl -sL https://get.docker.io/ | sh; apt-get install -y lxc-docker-0.6.4"
  not_if "dpkg --get-selections | grep -v deinstall | grep lxc-docker-0.6.4"
end

cookbook_file '/etc/init/docker.conf' do
   source "docker.conf"
   owner 'root'
   group 'root'
   mode '0644'
end


#******************************************************************************************
#  Set up everything involved in the ruby environment and the app
#******************************************************************************************

# make sure bundler is installed
gem_package "Installing Bundler #{node[:bundler][:version]}" do
  gem_binary node[:dependencies][:gem_binary]
  retries 2
  package_name "bundler"
  action :install
  version node[:bundler][:version]
end


node[:deploy].each do |application, deploy|
  
   Chef::Log.debug("*** Start here ***")
   Chef::Log.debug("Deploying #{application} with vars #{deploy.inspect}")

   # add the deploy user
   opsworks_deploy_user do
     deploy_data deploy
     app application
   end
   
   # pull down the app code
   opsworks_deploy do
     deploy_data deploy
     app application
   end
   
   directory "#{deploy[:deploy_to]}/shared" do
     group deploy[:group]
     owner deploy[:user]
     mode 0770
     action :create
     recursive true
   end

   ['log','pids'].each do |dir_name|
     directory "#{deploy[:deploy_to]}/shared/#{dir_name}" do
       group deploy[:group]
       owner deploy[:user]
       mode 0770
       action :create
       recursive true
     end
   end
   
   directory "#{deploy[:deploy_to]}/current" do
     group deploy[:group]
     owner deploy[:user]
     mode 0770
     action :create
     recursive true
   end

   dotenv_create do
     environment deploy[:environment]
     path        "#{deploy[:deploy_to]}/current"
     group       deploy[:group]
     user        deploy[:user]
   end
   
   # run bundle install
   env = deploy[:environment]["RACK_ENV"]
   without = ["development", "test", "staging", "production"]
   without -= [env] if env
   without = without.join(' ')

   args = []
   args << "--deployment"
   args << "--without #{without}"
   args << "--path vendor/bundle"

   execute "bundle install #{args.join(" ")}" do
     cwd   "#{deploy[:deploy_to]}/current"
     user  deploy[:user]
   end
   
   
end


#******************************************************************************************
#  Start god hipache
#******************************************************************************************


# run god and thus the workers
god_monitor "workers" do
  config        "workers.god.erb"
  group         "pyxie"
  user          "pyxie"
  deploy_to     "/usr/local/app/current"
end

# kill workers with SIGTERM and let god start them up
ruby_block "kill_workers" do
  block do
    pids = Dir.glob("#{deploy[:deploy_to]}/shared/pids/*.pid").map { |f| File.read(f) }
    system("kill #{pids.join(' ')}") if pids.size > 0
  end
end



#******************************************************************************************
#  Set up hipache
#******************************************************************************************

include_recipe "nodejs::install_from_source"

#include_recipe "npm"
#npm_package "hipache" do
#  action :install
#end

cookbook_file '/etc/init/hipache.conf' do
   source "hipache.conf"
   owner 'root'
   group 'root'
   mode '0644'
end

template '/etc/hipache.conf' do
  source 'hipache.conf.erb'
  owner 'root'
  group 'root'
  mode '0644'
  variables(
    :redisHost => node['hipache']['redisHost']
  )
end

service 'hipache' do
  provider Chef::Provider::Service::Upstart
  supports :restart => true, :start => true, :stop => true
  action [:enable, :start]
end





