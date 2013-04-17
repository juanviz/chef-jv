#
# Cookbook global 
# Recipe:: remove temp folder
#
# Author:: Juan Vicente Herrera (<juan.vicente.herrera@gmail.com>)#
#
# Recipe only for global functionalities


################################################################
################################################################
# REMOVE TEMPORAL INSTALLATION 
################################################################
=begin
directory "#{node['project']['temp']['dir']}" do
	recursive true
	action :delete
end
=end