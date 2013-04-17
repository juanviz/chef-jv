
action :download do


	dest_dir = new_resource.dest_dir
	owner = new_resource.owner
	group = new_resource.group
	source = new_resource.source	
	
	remote_file "#{dest_dir}" do
		owner owner
		Chef::Log.info "get from: " + source
		source source
		mode "0755"
	end
	
end