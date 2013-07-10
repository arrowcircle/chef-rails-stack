define :unicorn_config do
  # create app_name.rb
  app_name = params[:name]
  app_path = params[:path]
  app_user = params[:user]
  shared_path = "#{app_path}/shared"
  config_path = "#{shared_path}/config"
  current_path = "#{app_path}/current"
  socket_path = "#{shared_path}/#{app_name}.sock"
  pid_path = "#{shared_path}/pids/#{app_name}.pid"
  workers = params[:workers] || 2
  timeout = params[:app_timeout] || 60
  domain_name = params[:domain_name]
  
  template "#{config_path}/#{app_name}.rb" do
    user app_user
    owner app_user
    source "unicorn.rb.erb"
    variables({
      :workers => workers,
      :timeout => timeout,
      :working_path => current_path,
      :socket_path => socket_path,
      :pid_path => pid_path,
      :shared_path => shared_path,
      :name => app_name
    })
  end

  # add init script
  template "/etc/init.d/#{app_name}" do
    user "root"
    owner "root"
    source "rails-init.erb"
    mode 00755
    variables({
      :current_path => current_path,
      :pid_path => pid_path,
      :cmd => "cd #{current_path}; bundle exec unicorn_rails -D -c #{config_path}/#{app_name}.rb -E production",
      :user => app_user
      })
  end
end