#
# Cookbook Name:: tomcat
# Recipe:: default
# Resource:: zip
#
# Copyright 2012, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

actions :install,:start,:stop,:restart

attribute :install_dir, :kind_of => String, :name_attribute => true
attribute :tarball, :kind_of => String,:default => "http://x.x.x.x/lite-env/tomcat7/apache-tomcat-7.0.32.tar.gz"
attribute :owner, :kind_of => String, :default => "root"
attribute :group, :kind_of => String, :default => "root"
attribute :port, :kind_of =>String,:default=>"8080"
attribute :ajp_port, :kind_of =>String, :default=>"8009"
attribute :server_port, :kind_of=>String,:default=>"8004"
attribute :shared_folder, :kind_of=>String,:default=>nil

def initialize(*args)
  super
  @action = :install
end
