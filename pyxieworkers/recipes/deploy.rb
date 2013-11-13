ENV['LANGUAGE'] = ENV['LANG'] = ENV['LC_ALL'] = "en_US.UTF-8"

include_recipe "apt"
include_recipe "ruby_build"
include_recipe "rbenv::user"
#include_recipe "redisio::install"
#include_recipe "redisio::enable"
#include_recipe "nodejs::default"
#include_recipe "docker::default"
#include_recipe "docker::upstart"

#include_recipe "npm"

node[:deploy].each do |application, deploy|
  
   Chef::Log.debug("*** Start here ***")
   Chef::Log.debug("Deploying #{application} with vars #{deploy.inspect}")

   # add the deploy user
   #opsworks_deploy_user do
  #   deploy_data deploy
  #   app application
   #end

   rbenv_gem "bundler" do
     rbenv_version   "1.9.3-p448"
     user            deploy[:user]
     version         "1.3.5"
     action          :install
   end

   dotenv_create do
     environment deploy[:environment]
     path        "#{deploy[:deploy_to]}/current"
     group       deploy[:group]
     user        deploy[:user]
   end
   
   
   # enable the  the docker.conf file to enable the docker API 
   #group "docker" do
   #  action :modify
   #  members "vagrant"
   #  append true
   #end
   #npm_package "hipache"

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

end
