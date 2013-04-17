#
# Cookbook Name:: environment-config
# Recipe:: default
#
# Copyright 2012, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#


################################################################
################################################################
# DATA BAGS
################################################################

# Retrieve databag users to obtain the user:group configured for this env
users_bag = data_bag_item('users', 'apps_users')

# Program Vbles env-dependent
s_user              = users_bag[node.chef_environment]["user"]
s_group             = users_bag[node.chef_environment]["group"]
file_server         = data_bag_item('fileserver', 'url')[node.chef_environment]
log_level           = data_bag_item('logging', 'level')[node.chef_environment]

# Elements downloading URLs
solr_dist_file_url  = file_server + node['solr']['dist_file_url']
home_dir = node['solr']['home_dir']
folder_dir = home_dir + node['solr']['folder_name']
solr_port = node['solr']['port'] 




# Download distribution tar.gz package (only download it if checksum differs)
# Checksum is configured as an attribute & overriden in environment when releasing a new revision

remote_file "/tmp/solr.tar.gz" do
    owner user
    group user
    mode "0644"
    source solr_dist_file_url
    checksum node['solr']['tarball_checksum']
    notifies :run, "bash[install-solr]",:immediately    
end


################################################################
################################################################
# UNCOMPRESS SOLR
################################################################
bash "install-solr" do
    user user
    cwd "/tmp"
    code <<-EOH
     #stop solr (if it is already installed)
     if [ -f #{folder_dir}/tomcat/bin/shutdown.sh ];
     then
       #{folder_dir}/tomcat/bin/shutdown.sh  
       echo "SOLR stopped, init installation...."
       echo "Removing previous SOLR installations..."
       rm -rf #{folder_dir}
     fi

     cd #{home_dir}
     tar -xvf /tmp/solr.tar.gz -C .
  
  EOH
end

# Set config for solr.solr.home variables 
#(through JAVA_OPTS as this installation uses tomcat in single mode for solr)
template "#{folder_dir}/tomcat/bin/catalina.sh" do
  source "catalina.sh.erb"
  owner s_user
  group s_group
  mode "0755"
end

# Set config for solr.solr.home variables 
#(through JAVA_OPTS as this installation uses tomcat in single mode for solr)
template "#{folder_dir}/tomcat/conf/server.xml" do
  source "server.xml.erb"
  owner s_user
  group s_group
  mode "0644"
end

################################################################
################################################################
# UNCOMPRESS SOLR
################################################################
bash "start-solr" do
    user user
    code <<-EOH
     
      #{folder_dir}/tomcat/bin/startup.sh  
      echo "Starting SOLR om port [#{solr_port}].........."
  EOH
end