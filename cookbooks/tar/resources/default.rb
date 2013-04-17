# Cookbook Name:: tar
# Recipe:: default
# Resource:: tar
#
# Copyright 2012, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

actions :uncompress

attribute :dest_dir, :kind_of => String, :name_attribute => true
attribute :owner, :kind_of => String, :default => "root"
attribute :group, :kind_of => String, :default => "root"
attribute :tarball, :kind_of => String,:default => ""

def initialize(*args)
  super
  @action = :uncompress
end





