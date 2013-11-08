include_recipe "dockervagrant"
include_recipe "nodejs"

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