ENV['LANGUAGE'] = ENV['LANG'] = ENV['LC_ALL'] = "en_US.UTF-8"

include_recipe "apt"
include_recipe "ruby_build"
include_recipe "rbenv::user"
include_recipe "rbenv::vagrant"
include_recipe "postgresql::server"
include_recipe "docker::default"
include_recipe "docker::upstart"
include_recipe "redisio::install"
include_recipe "redisio::enable"
include_recipe "nodejs"


rbenv_gem "bundler" do
  rbenv_version   "1.9.3-p448"
  user            node[:user]
  version         "1.3.5"
  action          :install
end

# enable the  the docker.conf file to enable the docker API 
group "docker" do
  action :modify
  members "vagrant"
  append true
end

