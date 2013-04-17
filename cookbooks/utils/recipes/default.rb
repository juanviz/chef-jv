#
# Cookbook global 
# Recipe:: default
#
# Author:: Juan Vicente Herrera (<juan.vicente.herrera@gmail.com>)#
#
# Recipe only for global functionalities

class Chef::Recipe
  include ProcessHelper
end

################################################################
################################################################
# LOCAL VARIABLES
################################################################

=begin Commented out, not needed anymore

################################################################
################################################################
# BLOCK RUBY REMOVE PROCESS RUNNING
################################################################

ruby_block "process_kill" do 
	block do
		local_pid = ProcessHelper.helper_get_pid_by_name("#{node['project']['name']}")
		ProcessHelper.helper_kill_process(local_pid)
		sleep(10) 
	end
end

################################################################
################################################################
# REMOVE LAST TEMP INSTALLATION 
################################################################

directory "#{node['project']['temp']['dir']}" do
	recursive true
	action :delete
end

directory "#{node['project']['temp']['dir']}" do
	owner node['project']['user']
	group node['project']['group']
	mode "0755"
	recursive true
	action :create
end

################################################################
################################################################
# GETTING THE INSTALLER FILE FROM THE REMOTE LOCATION
################################################################

remote_file "#{node['project']['temp']['dir']}""#{node['project']['installer']['name']}" do
	owner node['project']['user']
	group node['project']['group']
	Chef::Log.info "get from: " + node['project']['installer']['file']['url']
	source node['project']['installer']['file']['url']
	mode "0755"
end

################################################################
################################################################
# REMOVE LAST INSTALLATION 
################################################################

directory "#{node['project']['installer']['dir']}" do
	recursive true
	action :delete
end

directory "#{node['project']['installer']['dir']}" do
	owner node['project']['user']
	group node['project']['group']
	mode "0755"
	action :create
end

################################################################
################################################################
# TAR RESOURCE FOR UNCOMPRESS TO UNTAR FILE
################################################################

tar "#{node['project']['installer']['dir']}" do
	owner node['project']['user']
	tarball "#{node['project']['temp']['dir']}#{node['project']['installer']['name']}"
end


################################################################
################################################################
# CHANGE RIGHT
################################################################

ruby_block "change_permission" do
	block do
		uid = Etc.getpwnam("#{node['project']['user']}").uid
		gid = Etc.getpwnam("#{node['project']['group']}").uid
		file = "#{node['project']['installer']['untar']['dir']}"
		File.chmod(0755, file )
		File.chown(uid,gid, file)
	end
end
=end
