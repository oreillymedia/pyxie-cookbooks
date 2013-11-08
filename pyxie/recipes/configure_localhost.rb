ENV['LANGUAGE'] = ENV['LANG'] = ENV['LC_ALL'] = "en_US.UTF-8"

include_recipe "apt"
include_recipe "ruby_build"
include_recipe "rbenv::user"
include_recipe "rbenv::vagrant"
include_recipe "postgresql::server"
include_recipe "redisio::install"
include_recipe "redisio::enable"


rbenv_gem "bundler" do
  rbenv_version   "1.9.3-p448"
  user            node[:user]
  version         "1.3.5"
  action          :install
end


rbenv_script "bundle_install" do
 rbenv_version   "1.9.3-p448"
 user            node[:user]
 cwd             node[:deploy_to]
 code            "bundle install --without staging production"
end

rbenv_script "rake_db_create" do
 rbenv_version   "1.9.3-p448"
 user            node[:user]
 cwd             node[:deploy_to]
 code            "rake db:create"
end
