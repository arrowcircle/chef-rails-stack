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

include_recipe 'sudo'

node['apps'].each do |app|
  app app['name'] do
    user app['user']
    domain_name app['domain_name']
    ruby_version (app['ruby_version'] || node['default_ruby_version'])
  end
end

# database_part
db_servers = node['apps'].map(&:database).select {|db| db['server'] == true }
db_types = db_servers.map {|db| db['type']}.uniq

if (db_types.include? "postgresql")
  include_recipe 'postgresql'
  include_recipe 'postgresql::server'
  include_recipe 'postgresql::server_dev'
  include_recipe 'postgresql::contrib'
  include_recipe 'postgresql::libpq'

  pg_databases = db_servers.select {|d| d['type'] == 'postgresql'}

  pg_databases.each do |pgd|
    pg_user pgd['username'] do
      privileges :superuser => false, :createdb => true, :login => true
      password pgd['password']
    end

    pg_database "#{pgd['dbname']}" do
      owner pgd['username']
      encoding "utf8"
      template "template0"
      locale "ru_RU.UTF8"
    end

    pg_database_extensions "#{pgd['dbname']}" do
      extensions ["hstore"]
    end
  end
end

if (db_types.include? "mysql")
  include_recipe 'mysql'
  include_recipe 'mysql::server'

  user = 'root'
  root_password = node['mysql']['server_root_password']

  mysql_databases = db_servers.select {|d| d['type'] == 'mysql'}

  mysql_databases.each do |mdb|
    db_sql = <<-SQL
      CREATE DATABASE IF NOT EXISTS #{mdb['dbname']};
      GRANT ALL PRIVILEGES ON #{mdb['dbname']}.*
      TO '#{mdb['username']}'@'localhost' #{ " IDENTIFIED BY '#{mdb['password']}'" if mdb['password'].size > 0}
      WITH GRANT OPTION;
    SQL

    execute "mysql create #{mdb['dbname']} and #{mdb['username']}" do
      command "mysql -u root -p#{root_password} -e \"#{db_sql}\""
    end
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

