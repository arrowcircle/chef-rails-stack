if node['apps']
  node['apps'].each do |app|
    ruby_app app['name'] do
      user app['user']
      domain_names app['domain_names']
      ruby_version (app['ruby_version'] || node['default_ruby_version'])
    end
  end
end