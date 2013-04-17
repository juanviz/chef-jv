#
# Cookbook  starts the service if it's not running and enables it to start at system boot time
# Recipe:: default
#
# Author:: Juan Vicente Herrera (<juan.vicente.herrera@gmail.com>)#

#########################################################
# VARIABLES:
#########################################################
path = node['mongodb']['install']['path']
launcher = node['mongodb']['service']['name']

#########################################################
# Run mongo startup script
#########################################################

bash "start mongo" do
	user "lumata"
	cwd  path
	code <<-EOH
	 /etc/init.d/#{launcher} start
	EOH
end	 
