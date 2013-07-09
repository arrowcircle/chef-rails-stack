define :app do
  #create and enable nginx site

  template "#{node['nginx']['dir']}/sites-available/#{params[:name]}" do
    source "rails-site.erb"
    owner "root"
    group "root"
    mode 00644
    variables({
      :app_name => params[:name],
      :socket_path => "/home/#{params[:user]}/projects/#{params[:name]}/shared/#{params[:name]}.sock",
      :domain_name => params[:domain_name],
      :public_path => "/home/#{params[:user]}/projects/#{params[:name]}/current/public",
      })
  end

  nginx_site params[:name] do
    enable params[:name]
  end

  # add init script
  template "/etc/init.d/#{params[:name]}" do
    user "root"
    owner "root"
    source "rails-init.erb"
    mode 00755
    variables({
      :current_path => "/home/#{params[:user]}/projects/#{params[:name]}/current",
      :pid_path => "/home/#{params[:user]}/projects/#{params[:name]}/shared/pids/#{params[:name]}.pid",
      :cmd => "cd /home/#{params[:user]}/projects/#{params[:name]}/; bundle exec unicorn_rails -D -c /home/#{params[:user]}/projects/#{params[:name]}/shared/config/unicorn.rb -E production",
      :user => params[:user]
      })
  end

  # create unicorn.rb

  template "/home/#{params[:user]}/projects/#{params[:name]}/shared/config/unicorn.rb" do
    user params[:user]
    owner params[:user]
    source "unicorn.rb.erb"
    variables({
      :workers => 2,
      :timeout => 60,
      :working_path => "/home/#{params[:user]}/projects/#{params[:name]}",
      :name => params[:name]
    })
  end

  # create nginx site

  template "#{node['nginx']['dir']}/sites-available/#{params[:name]}" do
    source "rails-site.erb"
    owner "root"
    group "root"
    mode 00644
    variables({
      :app_name => params[:name],
      :socket_path => "/home/#{params[:user]}/projects/#{params[:name]}/shared/#{params[:name]}.sock",
      :domain_name => params[:domain_name]
    })
  end

  #create monit
  template "/etc/monit/conf.d/#{params[:name]}" do
    user "root"
    owner "root"
    source "unicorn.monitrc.erb"
    variables({
      :app_name => params[:name],
      :pid_path => "/home/#{params[:user]}/projects/#{params[:name]}/shared/#{params[:name]}.pid",
    })
  end

  app_user = params[:user]
  app_name = params[:name]
  # ruby part
  rbenv_ruby params[:ruby_version] do
    user app_user
    app_name app_name
  end
end