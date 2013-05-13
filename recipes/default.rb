execute "locale-gen" do
  command "locale-gen ru_RU.UTF-8"
end

include_recipe "apt"
include_recipe "users"
include_recipe "nodejs::install_from_package"
include_recipe "rbenv"
include_recipe "memcached"
include_recipe "nginx"

%w{imagemagick libmagickcore-dev libmagickwand-dev advancecomp gifsicle jpegoptim libjpeg-progs optipng pngcrush}.each do |pkg|
  package pkg
end

nginx_site '000-default' do
  enable false
end

case node['app_server']
when "unicorn" then include_recipe "unicorn"
when "puma" then include_recipe "puma"
end
include_recipe "database"

package "monit" do
  action :install
end

case node['app_server']
when "unicorn" then include_recipe "unicorn::monit"
when "puma" then include_recipe "puma::puma"
end

service "monit" do
  action [:enable, :start]
end

logrotate_app node["app_name"] do
  cookbook "logrotate"
  path "/home/#{node['users']['user']}/projects/#{node['app_name']}/shared/logs"
  options ["missingok"]
  frequency "daily"
  rotate 30
  create "644 #{node['users']['user']} adm"
end

service 'procps' do
  supports :restart => true
  action :nothing
end

template "/etc/sysctl.conf" do
  source "sysctl.conf.erb"
  owner "root"
  group "root"
  mode 0644
  notifies :restart, "service[procps]"
end