define :ruby_app do

  app_user = params[:user]
  app_name = params[:name]

  project_path = "/home/#{app_user}/projects/#{app_name}"
  shared_path = "#{project_path}/shared"
  current_path = "#{project_path}/current"
  public_path = "#{current_path}/public"
  socket_path = "#{shared_path}/#{app_name}.sock"
  pid_path = "#{shared_path}/pids/#{app_name}.pid"
  config_path = "#{shared_path}/config"
  domain_names = params[:domain_names]

  current_app = node['apps'].select {|a| a[:name] == app_name }.first

  case current_app['app_server']['type']
  when "unicorn"
    unicorn_config app_name do
      path project_path
      domain_names domain_names
      user app_user
      workers current_app['app_server']['workers'] || node['unicorn']['workers']
      app_timeout current_app['app_server']['timeout'] || node['unicorn']['timeout']
    end
  when "puma"
    puma_config app_name do
      path project_path
      domain_names domain_names
      user app_user
      workers current_app['app_server']['workers'] || node['puma']['workers']
      min_threads current_app['app_server']['min_threads'] || node['puma']['threads']['min']
      max_threads current_app['app_server']['max_threads'] || node['puma']['threads']['max']
    end
  end

  #create and enable nginx site
  template "#{node['nginx']['dir']}/sites-available/#{app_name}" do
    source "rails-site.erb"
    owner "root"
    group "root"
    mode 00644
    variables({
      :app_name => app_name,
      :socket_path => socket_path,
      :domain_names => domain_names,
      :public_path => public_path,
      })
  end

  nginx_site app_name do
    enable app_name
  end

  #create monit
  template "/etc/monit/conf.d/#{app_name}" do
    user "root"
    owner "root"
    source "app.monitrc.erb"
    variables({
      :app_name => app_name,
      :pid_path => pid_path,
    })
  end

  # ruby part
  rbenv_ruby params[:ruby_version] do
    user app_user
    app_name app_name
  end

  # logrotate
  logrotate_app app_name do
    cookbook "logrotate"
    path "#{shared_path}/logs"
    options ["missingok"]
    frequency "daily"
    rotate 30
    create "644 #{app_user} adm"
  end

  app_database app_name do
    info current_app
    config_path config_path
  end
end