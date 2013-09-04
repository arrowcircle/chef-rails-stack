if node['apps']
  node['apps'].each do |app|
    app_dir app['name'] do
      user app['user']
      ruby_version (app['ruby_version'] || node['default_ruby_version'])
    end
  end
end