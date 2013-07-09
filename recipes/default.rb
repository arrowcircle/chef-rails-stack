# general

execute "locale-gen" do
  command "locale-gen ru_RU.UTF-8"
end

include_recipe "apt"
include_recipe "nodejs::install_from_package"
include_recipe "memcached"
include_recipe "nginx"
include_recipe "rbenv"
# %w{imagemagick libmagickcore-dev libmagickwand-dev advancecomp gifsicle jpegoptim libjpeg-progs optipng pngcrush}.each do |pkg|
#   package pkg
# end

# # include_recipe "users"

# include_recipe "rbenv"

package "monit" do
  action :install
end

# %w{imagemagick libmagickcore-dev libmagickwand-dev advancecomp gifsicle jpegoptim libjpeg-progs optipng pngcrush}.each do |pkg|
#   package pkg
# end

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

nginx_site '000-default' do
  enable false
end

# set sudo group
groups = node['authorization']['sudo']['groups'].dup
groups << 'sudo'
users = node['authorization']['sudo']['users'].dup

node.set['authorization']['sudo']['users'] = users + node['apps'].map(&:user)
node.default['authorization']['sudo']['groups'] = groups
node.set['authorization']['sudo']['passwordless'] = true

node['apps'].each do |app|
  app_user app['user'] do
    authorized_keys app['authorized_keys'] if app['authorized_keys']
    known_hosts app['known_hosts'] if app['known_hosts']
    app_name app['name']
  end
end

require_recipe 'sudo'

node['apps'].each do |app|
  app app['name'] do
    user app['user']
    domain_name app['domain_name']
    ruby_version (app['ruby_version'] || "2.0.0-p247")
  end
end



# case node['app_server']
# when "unicorn" then include_recipe "unicorn"
# when "puma" then include_recipe "puma"
# end
# include_recipe "database"



# case node['app_server']
# when "unicorn" then include_recipe "unicorn::monit"
# when "puma" then include_recipe "puma::puma"
# end

# logrotate_app node["app_name"] do
#   cookbook "logrotate"
#   path "/home/#{node['users']['user']}/projects/#{node['app_name']}/shared/logs"
#   options ["missingok"]
#   frequency "daily"
#   rotate 30
#   create "644 #{node['users']['user']} adm"
# end

