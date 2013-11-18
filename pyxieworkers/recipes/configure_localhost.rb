ENV['LANGUAGE'] = ENV['LANG'] = ENV['LC_ALL'] = "en_US.UTF-8"

include_recipe "apt"
include_recipe "ruby_build"
include_recipe "rbenv::user"
include_recipe "rbenv::vagrant"
include_recipe "docker::default"
include_recipe "docker::upstart"
include_recipe "redisio::install"
include_recipe "redisio::enable"
include_recipe "nodejs::default"
#include_recipe "npm"


rbenv_gem "bundler" do
  rbenv_version   "1.9.3-p448"
  user            node[:user]
  version         "1.3.5"
  action          :install
end

# enable the  the docker.conf file to enable the docker API 
#group "docker" do
#  action :modify
#  members "vagrant"
#  append true
#end

#npm_package "hipache"

# make shared dirs
['log','pids'].each do |dir_name|
  directory "#{node[:deploy_to]}/#{dir_name}" do
    group node[:group]
    owner node[:user]
    mode 0770
    action :create
    recursive true
  end
end

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


