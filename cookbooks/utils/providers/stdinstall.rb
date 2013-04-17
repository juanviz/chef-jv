#
# Cookbook utils 
# Provider : stdinstall
#
# Author:: Juan Vicente Herrera (<juan.vicente.herrera@gmail.com>)#
#
# Executes common installation steps for common apps, by executing following steps
# 1. Remove and clean previous installation (done via this resource also)
# 2. Download tarball specified and uncompress it to the install_dir folder

class Chef::Resource
  include ProcessHelper
end

action :install do

	## Local variables (resource attribs)
	appexec = new_resource.name
	s_owner = new_resource.owner
	s_group = new_resource.group
	tarball = new_resource.tarball
	install_dir = new_resource.install_dir

	tmp_dir = "/tmp/#{appexec}"
	tarball_local_file = "#{tmp_dir}/#{appexec}.tar"


	################################################################
	################################################################
	# BLOCK RUBY REMOVE PROCESS RUNNING
	################################################################
	ruby_block "process_kill" do 
		block do
			local_pid = ProcessHelper.helper_get_pid_by_name(appexec)
			ProcessHelper.helper_kill_process(local_pid)
			sleep(10) 
		end
	end
	################################################################
	################################################################
	# REMOVE LAST TEMP INSTALLATION 
	################################################################

	
	 directory tmp_dir do
		recursive true
		action :delete
	end

	directory tmp_dir do
		owner s_owner
		group s_group
		mode "0755"
		recursive true
		action :create
	end

	################################################################
	################################################################
	# GETTING THE INSTALLER FILE FROM THE REMOTE LOCATION
	################################################################

	remote_file tarball_local_file do
		owner s_owner
		group s_group
		Chef::Log.info "get from: #{tarball}" 
		source tarball
		mode "0755"
		action :create_if_missing
	end

	################################################################
	################################################################
	# REMOVE LAST INSTALLATION 
	################################################################

	directory install_dir do
		recursive true
		action :delete
	end

	directory install_dir do
		owner s_owner
		group s_group
		mode "0755"
		action :create
	end

	################################################################
	################################################################
	# TAR RESOURCE FOR UNCOMPRESS TO UNTAR FILE
	################################################################

	tar install_dir do
		owner s_owner
		tarball tarball_local_file
	end


	################################################################
	################################################################
	# CHANGE RIGHTS
	################################################################

	ruby_block "change_permission" do
		block do
			uid = Etc.getpwnam(s_owner).uid
			gid = Etc.getpwnam(s_group).uid
			file = install_dir
			`chmod 0755 #{file}`
			`chown #{uid}:#{gid} #{file}`
		end
	end

end

