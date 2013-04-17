#
# Cookbook Name:: webserver_front
# Recipe:: default
#
# Author:: Juan Vicente Herrera (<juan.vicente.herrera@gmail.com>)#
#
#

package "rsyslog" do
	action :install
end


directory node['rsyslog-server']['logs']['dir'] do
  owner "jv"
  group "jv"
  mode "0755"
  action :create
end

template "/etc/rsyslog.conf" do
        source "syslog.conf.erb"
        owner "root"
        group "root"
        mode "0644"
end

service "rsyslog" do
	supports :status => true, :restart => true, :reload => true
	action [ :enable, :start ]
end


