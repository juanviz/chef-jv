app_name = 'wiki_app'
app_config = node[app_name]
app_secrets = Chef::EncryptedDataBagItem.load("secrets", app_name) 

include_recipe "apache2"
include_recipe "apache2::mod_php5" 

# Determine the master database
if node['roles'].include?('db')
  master_db_host = 'localhost'
else
  results = search(:node, "role:db AND chef_environment:#{node.chef_environment}")
  master_db_host = results[0]['ec2']['public_hostname']
end 
directory "#{app_config['config_dir']}" do
  owner "root"
  group "root"
  mode "0755"
  action :create
  recursive true
end


template "#{app_config['config_dir']}/LocalSettings.php" do
  source "LocalSettings.php.erb"
  mode 0440
  owner "root"
  group node['apache']['group']
  variables(
    'db_master' => {
      '$wgDBuser' => app_config['db_user'];
      '$wgDBpassword' => app_secrets[node.chef_environment]['db_pass'];
      '$wgDBname' => app_config['db_name'];
      '$wgDBserver' => master_db_host;
    } 
  )
end
