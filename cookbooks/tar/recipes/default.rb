#
# Cookbook Name:: webserver_front
# Recipe:: default
#
# Author:: Juan Vicente Herrera (<juan.vicente.herrera@gmail.com>)#
#
#

gem_package "sys-proctable" do
  action :install
end


package "tar" do
	action :install
end

# Configuration of templates.