define :puma_config do
  # create app_name.rb
  app_name = params[:name]
  app_path = params[:path]
  app_user = params[:user]
  shared_path = "#{app_path}/shared"
  config_path = "#{shared_path}/config"
  current_path = "#{app_path}/current"
  socket_path = "#{shared_path}/#{app_name}.sock"
  pid_path = "#{shared_path}/pids/#{app_name}.pid"
  state_path = "#{shared_path}/pids/#{app_name}.state"
  workers = params[:workers] || 0
  min_threads = params[:min_threads] || 0
  max_threads = params[:max_threads] || 16
  domain_name = params[:domain_name]
  puma_ctl = "pumactl -P #{pid_path} -S #{state_path}"
  prefix = "cd #{current_path}; RAILS_ENV=production bundle exec "
  
  template "#{config_path}/#{app_name}.rb" do
    user app_user
    owner app_user
    source "puma.rb.erb"
    variables({
      :workers => workers,
      :min_threads => min_threads,
      :max_threads => max_threads,
      :working_path => current_path,
      :socket_path => socket_path,
      :pid_path => pid_path,
      :state_path => state_path,
      :name => app_name
    })
  end

  # add init script
  template "/etc/init.d/#{app_name}" do
    user "root"
    owner "root"
    source "puma-init.erb"
    mode 00755
    variables({
      :current_path => current_path,
      :pid_path => pid_path,
      :state_path => state_path,
      :config_path => "#{config_path}/#{app_name}.rb",
      :start => "#{prefix}puma -C #{config_path}/#{app_name}.rb",
      :stop => "#{prefix}#{puma_ctl} stop",
      :restart => "#{prefix}#{puma_ctl} restart",
      :user => app_user
      })
  end
end