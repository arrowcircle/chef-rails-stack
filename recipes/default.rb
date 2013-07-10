# general
include_recipe "rails-stack::general"

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

# database_part

db_servers = node['apps'].map(&:database).select {|db| db['server'] == true }.map {|db| db.type}.uniq
log "DB_SERVERS: #{db_servers}"



# case node['app_server']
# when "unicorn" then include_recipe "unicorn"
# when "puma" then include_recipe "puma"
# end
# include_recipe "database"



# case node['app_server']
# when "unicorn" then include_recipe "unicorn::monit"
# when "puma" then include_recipe "puma::puma"
# end

