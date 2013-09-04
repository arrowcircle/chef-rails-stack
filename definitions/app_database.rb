define :app_database do
  info = params[:info]
  config_path = params[:config_path]
  app_user = info['user']
  db_type = case info['database']['type']
  when 'mysql' then 'mysql2'
  when 'postgresql' then 'postgresql'
  end

  template "#{config_path}/database.yml" do
    user app_user
    owner app_user
    source "database.yml.erb"
    variables({
      :db_type => db_type,
      :db_name => info['database']['dbname'],
      :db_user => info['database']['username'],
      :db_password => info['database']['password'],
      :host => info['database']['host']
    })
  end
end