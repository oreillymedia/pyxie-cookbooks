ENV['LANGUAGE'] = ENV['LANG'] = ENV['LC_ALL'] = "en_US.UTF-8"

include_recipe "apt"

include_recipe "redisio::install"
include_recipe "redisio::enable"


#******************************************************************************************
#  Set up docker
#******************************************************************************************

include_recipe "docker::binary"
include_recipe "docker::upstart"



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
#  Set up hipache
#******************************************************************************************

#include_recipe "nodejs::default"
#include_recipe "npm"

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

