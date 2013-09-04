# clients
if node['apps']
  node['apps'].map { |a| a['type'] }.uniq.each do |lib|
    case lib
    when 'postgresql'
      include_recipe 'postgresql'
      include_recipe 'postgresql::contrib'
      include_recipe 'postgresql::libpq'
    when 'mysql'
      include_recipe 'mysql'
    end
  end

  # servers

  db_servers = node['apps'].map(&:database).select {|db| db['server'] == true }
  db_types = db_servers.map {|db| db['type']}.uniq

  if (db_types.include? "postgresql")
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
end
