#
# Cookbook Name:: nagios-nrpe
# Recipe:: default
#
# Author:: Juan Vicente Herrera (<juan.vicente.herrera@gmail.com>)#
# All rights reserved - Do Not Redistribute
#

# Install rpmforge (by including the default recipe)

include_recipe "rpmforge"

# get remote location (url as string) of nrpe rpm


nagios_rpm_remote_source = node['nagios-nrpe']['file_source']

# check if we want to use the file server configured for this env
if node['nagios-nrpe']['use_fileserver_databag']
    file_server = data_bag_item('fileserver', 'url')[node.chef_environment]
    nagios_rpm_remote_source = file_server + node['nagios-nrpe']['file_source']
end

remote_file "/tmp/nagios-nrpe.rpm" do
    owner "root"
    group "root"
    mode "0644"
    source nagios_rpm_remote_source
    notifies :run, "bash[install-nrpe]",:immediately
    notifies :run, "bash[install-nagios-plugins]",:immediately
    
end



# install package (package will start nrpe daemon /etc/init.d/nrpe)
bash "install-nrpe" do
    user "root"
    cwd "/tmp"
    code <<-EOH
    yum -y localinstall /tmp/nagios-nrpe.rpm
    EOH
    action :nothing
end

bash "install-nagios-plugins" do
    user "root"
    cwd "/tmp"
    code <<-EOH
    yum -y install nagios-plugins-by_ssh nagios-plugins-disk nagios-plugins-dns nagios-plugins-dummy nagios-plugins-fping nagios-plugins-http nagios-plugins-icmp nagios-plugins-ide_smart nagios-plugins-ldap nagios-plugins-linux_raid nagios-plugins-load nagios-plugins-log nagios-plugins-mysql nagios-plugins-nagios nagios-plugins-nrpe nagios-plugins-ntp nagios-plugins-ping nagios-plugins-procs nagios-plugins-rpc nagios-plugins-snmp nagios-plugins-ssh nagios-plugins-swap nagios-plugins-tcp nagios-plugins-time nagios-plugins-ups nagios-plugins-users check_logfiles

    EOH
    action :nothing
end

template "/etc/nagios/nrpe.cfg" do
    source "nrpe.cfg.erb"
    owner "root"
    group "root"
    mode "0644"
end


#Configure SELINUX (disable it)
bash "disable selinux" do
    user "root"
    cwd "/tmp"
    code <<-EOH
    /usr/sbin/setenforce 0 
    sed -i 's/^SELINUX=.*/SELINUX=disabled/g' /etc/selinux/config
    EOH
end






