
action :uncompress do


	dest_dir = new_resource.dest_dir
	owner = new_resource.owner
	group = new_resource.group
	tarball = new_resource.tarball

	bash "extract-tarfile" do
		user owner		
		cwd "/tmp"
		code <<-EOH
		tar zxf #{tarball} -C #{dest_dir}
		EOH
	end

end