#
# Cookbook Name:: Ulimits setup
# Recipe:: default
#
# Copyright 2012, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#
################################################################
# This recipe changes the Ulimits for the indicated user.
################################################################

################################################################
# DATA BAGS
################################################################

# Retrieve databag users to obtain the user:group configured for this env
users_bag = data_bag_item('users', 'apps_users')

# Program Vbles env-dependent
app_user              = users_bag[node.chef_environment]["user"]
app_group             = users_bag[node.chef_environment]["group"]

################################################################
# Check and increase Open files limit
################################################################

if (node.has_key?"ulimit_custom_user")
    app_user = node["ulimit_custom_user"]
end

template "/etc/security/limits.conf" do
  source "#{node['ulimits']['file']['template']}"
  owner "root"
  group "root"
  mode "0644"
  variables({
    :app_group => app_group,
    :app_user => app_user
  })  
end
