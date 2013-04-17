#
# Cookbook Name:: groovy
# Recipe:: default
#

# Download tarballs (installer & libs)

s_user = node['groovy']['user'];
s_grp = node['groovy']['group'];
home = node['groovy']['home']
version  = node['groovy']['version']

# Create home dir if not exists
directory home do
	owner s_user
	group s_grp
	mode "0755"
	action :create
	recursive true
end

#download installation tarballs 
{
	node['groovy']['tarball_url'] => "#{home}/groovy.tar.gz",
	node['groovy']['libs_tarball_url'] => "#{home}/groovy_libs.tar.gz"
}.each do |k,v| 

# Dup variables (they are blocked as default inside map.each() function)
	name = v.dup
	source = k.dup

	remote_file name do
	  owner s_user
	  group s_grp
	  mode "0644"
	  source source
	end
end

# Untar packages and install them

bash "install-groovy" do
	user s_user
	cwd home
	code <<-EOH
	tar zxvf groovy.tar.gz
	tar zxvf groovy_libs.tar.gz
	ln -s  groovy-#{version} groovy
	cp lib/* groovy/lib/
	rm -r lib
	rm groovy.tar.gz groovy_libs.tar.gz
	EOH
	action :run
end

# add to path (via template)
# By adding template to /etc/profile.d/ folder, this will be loaded in the process of the login
# for users. 
# This template only contains a modification over PATH env variable to add groovy/bin to path
template "/etc/profile.d/groovy.sh" do
	source "groovy_profile.sh"
	owner "root"
	group "root"
	mode "0655"
end

