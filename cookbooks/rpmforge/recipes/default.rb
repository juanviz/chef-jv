#
# Cookbook Name:: rpmforge
# Recipe:: default
#
# Copyright 2013, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#


# Download rpm file and install it
#

rpm_remote_source = node['rpmforge']['remote_path'] 
if node['rpmforge']['use_databag_fileserver'] = false
    file_server = data_bag_item('fileserver', 'url')[node.chef_environment]
    rpm_remote_source = file_server +  node['rpmforge']['remote_path']  
end
Chef::Log.info "remmote url: => " + rpm_remote_source
remote_file "/tmp/rpmforge.rpm" do
    owner "root"
    group "root"
    mode "0644"
    source rpm_remote_source
    notifies :install, "package[rpmforge]",:immediately
    
end


# install package (package will start nrpe daemon /etc/init.d/nrpe)
package "rpmforge" do
  action :nothing
  source "/tmp/rpmforge.rpm"
end


