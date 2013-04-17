#
# Cookbook Name:: redis-master
# Recipe:: default
#
# Copyright 2012, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

################################################################
################################################################
# DATA BAGS
################################################################

log_level = data_bag_item('logging', 'level')[node.chef_environment]
log_facilities = data_bag_item('logging', 'facilities')



##############################################################
# Install make package, if not present:
##############################################################
package "make" do
 action :install
end

##############################################################
# Install redis from jv-redis.tgz package
##############################################################
script "install_redis_from_source" do
  interpreter "bash"
  user "root"
  group "root"
  cwd "/tmp"
  code <<-EOH
    rm -rf redis*
    wget http://x.x.x.x/installers/redis/redis-jv.tgz
    tar -zxf redis-jv.tgz
    cd redis-2.6.5
    make install
    cd ..
    rm -rf redis*
    rm -f /etc/redis.conf
    cd /opt/jv/
    mkdir -p redis dbs logs
    chown -R jv:jv /opt/jv/*
  EOH
end

##############################################################
# Set server overcommit memory as for redis recommendations
##############################################################
bash "set vm.overcommit_memory = 1" do
    user "root"
    code <<-EOH
      sysctl vm.overcommit_memory=1 
      echo "vm.overcommit_memory=1" >> /etc/sysctl.conf
    EOH
end

##############################################################
# Set the ulimits for redis server
##############################################################
template "/etc/security/limits.conf" do
  source "limits.conf.erb"
  mode 0644
  owner "root"
  group "root"
end

##############################################################
# Put the customized startup script
##############################################################
template "/etc/init.d/redis" do
  source "redis.erb"
  mode 0755
  owner "root"
  group "root"
end

##############################################################
# Put the customized config. file
##############################################################
template "/opt/jv/redis/redis.conf" do
  source "redis.conf.erb"
  mode 0644
  owner "jv"
  group "jv"
        variables({
            :log_level => log_level,
            :log_facilities => log_facilities
        })

end

##############################################################
# Register redis as a service at startup
##############################################################
bash "register_service" do
  user "root"
  code <<-EOH
    chkconfig --add redis
    chkconfig redis on
  EOH
end

##############################################################
# Launch redis
##############################################################
service "redis" do
  action [:enable, :start]
end
