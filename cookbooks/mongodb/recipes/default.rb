#
# Cookbook mongodb - instance 
# Recipe:: default
#
# Author:: Juan Vicente Herrera (<juan.vicente.herrera@gmail.com>)#
#
###############################################################

# To launch mongo we need numactl command. We add the dependence so chef will execute numactl recipe.
include_recipe "numactl"

################################################################
# DETERMINE FILE-SERVER TO USE  
################################################################

# Define local fileserver: 
fileserver = node['mongodb']['local-fileserver-url']	# must be defined in the env's override attributes. 
use_databag = node['mongodb']['fileserver-databag']

# If using databag (default) then override fileserver with databag's URL
if use_databag
   fileserver = data_bag_item('fileserver', 'url')[node.chef_environment]
end


################################################################
# VARIABLES
################################################################

url  = fileserver + node['mongodb']['url']
user = node['mongodb']['user']
group = node['mongodb']['group']
fspt = node['mongodb']['fs']['path'] #filesystem path for ebs
path = node['mongodb']['install']['path']
data = node['mongodb']['data']['path']
logs = node['mongodb']['log']['dir'] 
launcher = node['mongodb']['service']['name']
init_script = "/etc/init.d/#{node['mongodb']['service']['name']}"

################################################################
# CREATE REQUIRED FOLDERS FOR ISNTALLATION 
################################################################
# Using an array of all folders required, in a loop
# according to best practices (foodcritic => FC005: Avoid repetition of resource declarations)

[path,data,fspt,logs].each do |folder|
    dir = folder.dup
    directory dir do
        owner user
        group group
        mode "0755"
        recursive true    
        action :create
    end    
end


## download mongo binary
remote_file "/tmp/mongo.tar.gz" do
    owner user
    group group
    mode "0644"
    source url
    notifies :run, "bash[install-mongo]",:immediately    
end


# Install mongo (by untar it), action nothgin by default,
# if a new binay is downloaded, then run action is performed
bash "install-mongo" do
    user user
    cwd "/tmp"
    code <<-EOH

    # Stop service if it is already installed
     if [ -f #{init_script} ];
     then
          echo "#{node['mongodb']['service']['name']} is installed, stopping service...."
          #{init_script} stop
          echo "#{node['mongodb']['service']['name']} stopped, init installation...."
     fi
     
     if [ -d #{path} ];
     then
        echo "Removing previous installation..."
        rm -rf #{path}/mongodb*
     fi
     echo "Installing new version for mongo..."
     tar zxf /tmp/mongo.tar.gz -C #{path}  
    EOH
    action :nothing    
   notifies :run,"bash[restart-mongo-service]"
end

# generate init script
# add_to_init-d recipe of this cookbook has been removed as it has no sense to have
# a recipe that is only called from this one (but not as separate recipe)

aux = []
config_nodes = search(:node,"role:mongodb-config AND chef_environment:#{node.chef_environment}")
config_nodes.each do  |n|
    aux.push("#{n.name}:#{n['mongodb']['port']}")
end
mongos_configmode = "--configdb #{aux.join(',')}" 

# if a change is made to the template, restart service
template init_script do
  source	"#{node['mongodb']['service']['name']}.erb"
  mode		"0755"
  owner		"root"
  group		"root"
  variables({
      :mongos_configmode => mongos_configmode
  })
  notifies :run,"bash[restart-mongo-service]"
end

###############################################################
# SET MONGO SERVICE AT STARTUP
################################################################
# This resource only enables service at startup if it is not added yet
service node['mongodb']['service']['name'] do
    action :enable 
end

#################################################################
# START SERVICE MONGO
#################################################################
# Srvice restart is done only if  node['mongodb']['service']['auto_start'] == true
# Also, this ruby block is executed (:create action executed) on-demand,
# other resources will have the responsibility to doing it (notifications)

bash "restart-mongo-service" do
    user user
    cwd "/tmp"
    code <<-EOH
    if #{node['mongodb']['service']['auto_start']};
    then
     #{init_script} stop
     #{init_script} start 
    else
      echo "Mongo Autostart attribute (mongodb::service::auto_start) disabled in this node". Doing nothing
    fi
    EOH
    action :nothing
end
