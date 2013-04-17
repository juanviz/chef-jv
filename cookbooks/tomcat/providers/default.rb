#
# Cookbook Name:: tomcat
# Recipe:: default
# Provider:: zip
#
# Copyright 2012, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#
# Install an instance of tomcat 7 and deploy the files specified in deploy_files array

action :install do

	tarball = new_resource.tarball
	wd = new_resource.install_dir
	s_user = new_resource.owner
	s_group = new_resource.group
	tomcat_home = "#{wd}/tomcat"
	shared_folder = new_resource.shared_folder	

	if tarball == nil
		Chef::Application.fatal!("Tarball attribute is required for action :install")		
	end

	remote_file "/tmp/apache-tomcat-7.0.32.tar.gz" do
	  owner s_user
	  group s_group
	  mode "0644"
	  source tarball
	  action :create_if_missing
	end

	directory wd do
		owner s_user
		group s_group
		mode "0755"
		action :create
		recursive true
	end
	

	bash "install_tomcat" do
		user s_user
		group s_group
		cwd wd
		code <<-EOH
		cp /tmp/apache-tomcat-7.0.32.tar.gz .
		tar zxvf apache-tomcat-7.0.32.tar.gz
		ln -s apache-tomcat-7.0.32 tomcat
		rm -rf apache-tomcat-7.0.32.tar.gz
		EOH
			
	end

	# Configure ports
	template "#{wd}/tomcat/conf/server.xml" do
		source "server.xml.erb"
		owner s_user
		group s_group
		cookbook "tomcat"
		mode "0644"
		variables({
		    :port => new_resource.port,
		    :ajp_port => new_resource.ajp_port,
		    :serverport =>new_resource.server_port
		  })
	end

	## If shared folder parameter is passed, we create the shared folder
	## and indicate where it is in catalina.properties.
	if (shared_folder != nil) then
		directory "#{wd}/tomcat/#{shared_folder}" do
	                owner s_user
        	        group s_group
                	mode "0755"
	                action :create
        	        recursive true
	        end

		template "#{wd}/tomcat/conf/catalina.properties" do
	                source "catalina.properties.erb"
        	        owner s_user
                	group s_group
	                cookbook "tomcat"
        	        mode "0644"
                	variables({
	                    :shared_folder => shared_folder
        	          })
	       	end


	end
	
end


action :start do
	Chef::Log.info "Starting tomcat at #{new_resource.install_dir}/tomcat"
	tomcat_start new_resource.install_dir
end

action :stop do
	Chef::Log.info "Stopping tomcat at #{new_resource.install_dir}/tomcat"
	tomcat_stop new_resource.install_dir
end

action :restart do
	Chef::Log.info "Restarting tomcat at #{new_resource.install_dir}/tomcat"
	tomcat_stop new_resource.install_dir
	tomcat_start new_resource.install_dir
end

def tomcat_start(path_tomcat)

	scrp = bash "start-tomcat" do
		user new_resource.owner
		cwd "#{path_tomcat}/tomcat/bin"
		code <<-EOH
		sh catalina.sh start
		EOH
		action :nothing
	end
	scrp.run_action(:run)
	new_resource.updated_by_last_action(true) if scrp.updated_by_last_action?
end

def tomcat_stop(path_tomcat)
	scrp = bash "stop-tomcat" do
		user new_resource.owner
		cwd "#{path_tomcat}/tomcat/bin"
		code <<-EOH
		sh catalina.sh stop
		EOH
		action :nothing
	end
	scrp.run_action(:run)
	new_resource.updated_by_last_action(true) if scrp.updated_by_last_action?
end

