define :app_user do
  user params[:name] do
    supports :manage_home => true
    comment "Rails production user"
    home "/home/#{params[:name]}"
    shell "/bin/bash"
    password (0...32).map{ ('a'..'z').to_a[rand(26)] }.join
    action :create
    not_if("ls /home | grep #{params[:name]}")
  end

  sudo_group = "sudo"

  group sudo_group do
    action :modify
    members params[:name]
  end

  execute "generate ssh key for user" do
    user params[:name]
    command "ssh-keygen -t rsa -q -f /home/#{params[:name]}/.ssh/id_rsa -P \"\""
    not_if { File.exists?("/home/#{params[:name]}/.ssh/id_rsa") }
  end

  template "/home/#{params[:name]}/.ssh/authorized_keys" do
    user params[:name]
    owner params[:name]
    source "keys.erb"
    mode 0600
    variables({:keys => params[:authorized_keys]})
    only_if { params[:authorized_keys] }
  end

  template "/home/#{params[:name]}/.ssh/known_hosts" do
    user params[:name]
    owner params[:name]
    source "keys.erb"
    mode 0600
    variables({:keys => params[:known_hosts]})
    only_if { params[:known_hosts] }
  end

  # ruby part

  template "/home/#{params[:name]}/.gemrc" do
    user params[:name]
    owner params[:name]
    source "gemrc.erb"
  end

  rbenv_user params[:name]
end