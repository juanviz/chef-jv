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
# Use library node_resolver to get info about endpoints of components
# needed for giddra
components = endpoints("rsyslog")





################################################################
################################################################
# RECIPE
################################################################

package "rsyslog" do
	action :install
end


directory node['rsyslog']['logs']['dir'] do
  owner "jv"
  group "jv"
  mode "0755"
  action :create
end


################################################################
################################################################
# We look for all node's syslog facility and logname (using SEARCH)
################################################################
facilities = {}

nodes = search(:node,"chef_environment:#{node.chef_environment}")

nodes.each do |n|
  if (n.has_key?"rsyslog")
    if(n["rsyslog"].has_key?"facility" and n["rsyslog"].has_key?"logname")
      name = n["rsyslog"]["logname"]
      facility = n["rsyslog"]["facility"]
      facilities[facility] = name
    end
  end
end


template "/etc/rsyslog.conf" do
        source "syslog.conf.erb"
        owner "root"
        group "root"
        mode "0644"
	variables({
	    :components => components,
            :log_level => log_level,
            :log_facilities => facilities
        })

end

service "rsyslog" do
	supports :status => true, :restart => true, :reload => true
	action [ :enable, :restart ]
end