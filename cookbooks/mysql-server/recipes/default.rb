#
# Cookbook Name:: mysql-server
# Recipe:: default
#
# Copyright 2012, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#
##############################################################
# Install MySQL-Server 5.1
##############################################################

package "mysql51-server" do
  action :install
end

##############################################################
# Create MySQL directories
##############################################################

# DBs path:
directory node['dbs']['path'] do
  owner  "jv"
  group  "jv"
  mode   "0755"
  path node['dbs']['path']
  recursive true
  action :create
end

# MySQL DB path:
directory node['mysql-server']['db']['path'] do
  owner  "jv"
  group  "jv"
  mode   "0755"
  path node['mysql-server']['db']['path']
  recursive true
  action :create
end

# Logs path:
directory node['mysql-server']['logs']['path'] do
  owner  "jv"
  group  "jv"
  mode   "0755"
  path node['mysql-server']['logs']['path']
  recursive true
  action :create
end

# Config path:
template node['mysql-server']['conf']['path'] do
  source "my.cnf"
  mode 0755
  owner "jv"
  group "jv"
end

##############################################################
# Register MySQL at Startup
##############################################################

utils_register_service "mysqld" do
action :register
end

##############################################################
# Launch MySQL
##############################################################

service "mysqld" do
  action :enable
  action :stop
  action :start
end