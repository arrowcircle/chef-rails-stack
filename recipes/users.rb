# set sudo group
groups = node['authorization']['sudo']['groups'].dup
groups << 'sudo'
users = node['authorization']['sudo']['users'].dup

node.set['authorization']['sudo']['users'] = users + node['users'].map(&:user)
node.set['authorization']['sudo']['groups'] = groups
node.set['authorization']['sudo']['passwordless'] = true

node['users'].each do |user|
  app_user user['user'] do
    authorized_keys user['authorized_keys'] if user['authorized_keys']
    known_hosts user['known_hosts'] if user['known_hosts']
    # app_name user['name']
  end
end

include_recipe 'sudo'

group "sudo" do
  action :modify
  members "vagrant"
  append true
  only_if ("ls /home | grep vagrant")
end