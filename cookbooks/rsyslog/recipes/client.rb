#
# Cookbook Name:: webserver_front
# Recipe:: default
#
# Author:: Juan Vicente Herrera (<juan.vicente.herrera@gmail.com>)#
#
#


################################################################
################################################################
# DATA BAGS
################################################################

log_level = data_bag_item('logging', 'level')[node.chef_environment]
log_facilities = data_bag_item('logging', 'facilities')


package "rsyslog" do
	action :install
end


template "/etc/rsyslog.conf" do
        source "syslog_client.conf.erb"
        owner "root"
        group "root"
        mode "0644"
        variables({
            :log_level => log_level,
            :log_facilities => log_facilities
        })

end

service "rsyslog" do
	supports :status => true, :restart => true, :reload => true
	action [ :enable, :start ]
end


