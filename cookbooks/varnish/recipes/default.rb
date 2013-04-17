#
# Cookbook Name:: webserver_front
# Recipe:: default
#
# Author:: Juan Vicente Herrera (<juan.vicente.herrera@gmail.com>)#
#
#
#################################################
# DATA BAGS
#################################################

components = endpoints("alfresco")

#################################################
# VARIABLES DEFINITION
#################################################

vcl = node['varnish']['default-vcl']['path']
sysconfvarnish = node['varnish']['sysconfig-varnish']['path']
launcher = node['varnish']['launcher']

#################################################
# INSTAL AND CONFIGURE
#################################################

#install varnish
package "varnish" do
	action :install
end

# Configuration #1 (etc/varnish/Default.vcl)
template "#{vcl}" do
	source "default.vcl.erb"
	owner "root"
	group "root"
	mode "0644"
	variables({
         :components => components
        })

end

# Configuration #2 (etc/sysconfig/varnish)
template "#{sysconfvarnish}" do
	source "sysconfig-varnish.erb"
	owner "root"
	group "root"
	mode "0644"
end

# Replace Startup script (etc/init.d/varnish)
template "#{launcher}" do
	source "varnish.erb"
	owner "root"
	group "root"
	mode "0755"
end

#################################################
# REGISTER BOTH VARNISH PROCESSES AT STARTUP
#################################################

utils_register_service "varnish" do
action :register
end

utils_register_service "varnishlog" do
action :register
end

#################################################
# START BOT PROCESSES (IF STOPPED)
#################################################

bash "start varnish" do
	user "root"
	code <<-EOH
     /etc/init.d/varnish start
     /etc/init.d/varnishlog start
	EOH
end	 



