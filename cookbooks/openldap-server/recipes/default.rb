#
# Cookbook Name:: openldap-server
# Recipe:: default
#
# Author:: Juan Vicente Herrera (<juan.vicente.herrera@gmail.com>)#
#
#


###
##		DATA BAGS
###
fileserver = data_bag_item('fileserver', 'url')[node.chef_environment]


###
#	Installer variables definition, defined in attributes.
#	
###
openldap_server_installer_location = node['openldap_server']['installer']['dir'] + node['openldap_server']['installer']['name']   ## where to place the installer during installation
openldap_server_installer_url = fileserver + node['openldap_server']['installer']['file']['url']
openldap_schema_url = fileserver + node['openldap_server']['schema']['url']
openldap_ldif_url = fileserver + node['openldap_server']['ldif']['url']
openldap_config_file = "/etc/openldap/slapd.conf"

user = node['ldap']['user']
group = node['ldap']['group']

##
#	Environment variables definition
##
openldap_server_installer_name = node['openldap_server']['installer']['name']
openldap_server_installer_dir = node['openldap_server']['installer']['dir']
openldap_server_installer_profile = node['openldap_server']['installer']['profile']
openldap_server_dir = node['openldap_server']['installer']['dir'] + "LDAP/"
openldap_schema_location = openldap_server_dir + "schema.tar.gz"
openldap_ldif = openldap_server_dir + "jv.ldif"

#####################################################
###
##	INSTALLATION
###
#####################################################


##
#	INSTALLING THE PACKAGE
##
package "openldap-servers" do
  action :install
end


###
#	Applying the workaround for this slapd version, we have to indicate the configuration file when starting the service in order for it to actually recognize the file.
###
template "/etc/init.d/slapd" do
	source "slapd.erb"
	owner user
	group group
	mode "0744"
	variables({
        	:openldap_config_file => openldap_config_file
        })

end



###
#       Creating the installation location
###
directory openldap_server_dir do
  owner         "#{user}"
  group         "#{group}"
  recursive     true
  mode          "0755"
  action        :create
end



###
#	Getting the installer file from the remote location
###
remote_file openldap_server_installer_location do
  user "jv"
  source openldap_server_installer_url
  mode "0755"
#  checksum "08da002l" # A SHA256 (or portion thereof) of the file.
end


###
#       Getting the schemas from the remote location
###
remote_file openldap_schema_location do
  user "jv"
  source openldap_schema_url
  mode "0755"
end


###
#       Getting the schemas from the remote location
###
remote_file openldap_ldif do
  user "jv"
  source openldap_ldif_url
  mode "0755"
end

 
###
#
#	Script to install openldap_server, given the installer in the file server.
#
###
script "install_openldap_server" do
  interpreter "bash"
  user "root"         ## We install as user "jv" to /opt/jv
  cwd "/tmp"

environment 'OPENLDAP_SERVER_INSTALLER_NAME' => openldap_server_installer_name, 'OPENLDAP_SERVER_INSTALLER_DIR' => openldap_server_installer_dir, 'OPENLDAP_SERVER_DIR' => openldap_server_dir, 'OPENLDAP_SCHEMA' => openldap_schema_location, 'OPENLDAP_LDIF' => openldap_ldif

  code <<-EOH

  cd $OPENLDAP_SERVER_INSTALLER_DIR

  tar xzf $OPENLDAP_SERVER_INSTALLER_NAME -C ./

  cd $OPENLDAP_SERVER_DIR



#########################################################################
##	Cleaning previous databases and stopping the service	#########
#########################################################################

  rm -rf /var/lib/ldap/*
  
  /etc/init.d/slapd stop


#########################################
##	We place all our schemas	#
#########################################

  cp $OPENLDAP_SCHEMA /etc/openldap/

  cd /etc/openldap/

  mv schema schema_original

  tar xzvf $OPENLDAP_SCHEMA

  cd $OPENLDAP_SERVER_DIR


###########################################
###  We copy the configuration file	###
###########################################

  cp ./slapd.conf /etc/openldap/

  /etc/init.d/slapd start

############################################################################################## ---> WARNING, this ldap version doesn't work well with regular start script!!  
#  /usr/sbin/slapd -f /etc/openldap/slapd.conf -u ldap

#################################
###  We load the jv ldiff	#
#################################

  sleep 7

  echo $OPENLDAP_LDIF

  ldapadd -H ldap://localhost:389 -f $OPENLDAP_LDIF -x -D "cn=Manager,dc=frog,dc=buongiorno,dc=com" -w frog2011

#################################
###  Configuring the service	#
#################################

  chkconfig slapd on

  cd $OPENLDAP_SERVER_INSTALLER_DIR

  rm -rf $OPENLDAP_SERVER_INSTALLER_NAME

#####################################
###  Deleting the temporal files    #
#####################################

#  rm -rf $OPENLDAP_SERVER_DIR

  EOH
end
