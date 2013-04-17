# Cookbook Name:: utils
# Recipe:: default
# Resource:: standar
#
# Copyright 2012, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#
# Performs an standard installation of a common app

actions :install


attribute :name, :kind_of => String, :name_attribute => true
attribute :group, :kind_of => String, :default => "root"
attribute :owner, :kind_of => String, :default => "root"
attribute :tarball, :kind_of =>String,:default=> nil
attribute :install_dir, :kind_of =>String, :default=> nil

def initialize(*args)
  super
  @action = :install
end