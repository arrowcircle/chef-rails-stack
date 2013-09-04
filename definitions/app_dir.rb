define :app_dir do

  username = params[:user]
  name = params[:name]

  pre = "/home/#{username}/projects"
  working_path = "#{pre}/#{name}"
  shared_path = "#{pre}/#{name}/shared"

  dirs = [
      "#{pre}",
      "#{working_path}",
      "#{working_path}/releases",
      "#{shared_path}",
      "#{shared_path}/uploads",
      "#{shared_path}/config",
      "#{shared_path}/log",
      "#{shared_path}/tmp",
      "#{shared_path}/pids"
    ]

  dirs.each do |dir|
    directory dir do
      owner username
      user username
      group username
      mode 00775
      action :create
    end
  end
end