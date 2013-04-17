#
# Cookbook Name:: rabbitmq-server
# Recipe:: default
#
#
# Author:: Juan Vicente Herrera (<juan.vicente.herrera@gmail.com>)#
#
# 
# Download remote files from file server (configured in Chef:;Config[file_cache_path)
#
# Files downloaded are: 
# * rabbit.tgz : installable packages
# * rabbitmqadmin.py: admin script
# * rabbit_broker_definitions.json: broker definitions
fileserver = data_bag_item('fileserver', 'url')[node.chef_environment]
Chef::Log.info "fileserver value: #{fileserver}"
tgz_remote_package = fileserver + node['rabbitmq-server']['tgz_package_url']
rabbitmqadmin_remote_package = fileserver + node['rabbitmq-server']['rabbitmqadmin_url']
broker_definitions_remote = fileserver + node['rabbitmq-server']['broker_definitions_url']

###
#   Load users & groups
###
users_bag = data_bag_item('users', 'apps_users')
rabbitmq_group = users_bag[node.chef_environment]["group"] 
rabbitmq_user = node['rabbitmq-server']['user']

#if node['rabbitmq-server']['use_databag_user']
#  users_bag = data_bag_item('users', 'apps_users')
#  user = users_bag[node.chef_environment]["user"]
#  group = users_bag[node.chef_environment]["group"]  
#end

remote_file "/tmp/rabbit.tgz" do
    source tgz_remote_package
    action :create_if_missing
end

remote_file "/usr/sbin/rabbitmqadmin.py" do
    source rabbitmqadmin_remote_package
    mode "0755"
    action :create_if_missing    
end

remote_file "/tmp/rabbit_broker_definitions.json" do
    source broker_definitions_remote
    action :create_if_missing
end

########################################################################
# Installation of rabbitmq-server
########################################################################

Chef::Log.info "Configuring files"

# Install erlang before (it is a dependence for rabbitmq)

script "install rabbitmq and erlang" do
  interpreter "bash"
  user "root"
  group "root"
  cwd "/tmp"
  code <<-EOH
    tar -zxf rabbit.tgz
    cd rabbitmq4amazonlinux
    yum -y remove rabbit* atk* tk* unixODBC* SDL* gtk2*
    yum  --enablerepo=epel -y install *.rpm
    cd ..
#    rm -rf rabbit.tgz
  EOH
end

#
# Configuration file: data and logs paths, listening port:
#
directory "/etc/rabbitmq" do
  owner "root"
  group "root"
  mode 00755
  action :create
end
template "/etc/rabbitmq/rabbitmq-env.conf" do
  source "rabbitmq-env.conf.erb"
  mode "0755"
  owner "root"
  group "root"
end
#
# Configuration file for rabbitmq-server web-console port:
#
template "/etc/rabbitmq/rabbitmq.config" do 
    source "rabbitmq.config.erb"
    mode "0755"
    owner "root"
    group "root"
end
#
#   Create RabbitMQ data and logs directory
#
directory "/opt/lumata/rabbitmq" do
  owner rabbitmq_user
  group rabbitmq_group
  mode 00755
  action :create
end
#
# Enable plugins
#
Chef::Log.info "Enabling plugins...."
execute "/usr/sbin/rabbitmq-plugins enable rabbitmq_management" do
    action :run
end

#
# Enable and start service
#
utils_register_service "rabbitmq-server" do
action :register
end 

service "rabbitmq-server" do
  action :start
end

#
# Clear rabbitmq (return it to its virgin state). Removes all queues, cluster and information in rabbitmq.
#
script "Reset rabbitmq" do
  interpreter "bash"
  user "root"
  group "root"
  cwd "/tmp"
  code <<-EOH
	rabbitmqctl stop_app

	rabbitmqctl reset

	rabbitmqctl start_app
  EOH
end


#
# import broker definitions
#
Chef::Log.info "Loading broker definitions..."
execute "/usr/sbin/rabbitmqadmin.py -q -P #{node['rabbitmq-server']['mochiweb']['listen_port']} import /tmp/rabbit_broker_definitions.json " do
    action :run
end

Chef::Log.info "Deleting /tmp files"
execute "rm -Rf /tmp/rabbit*" do
    action :run
end
